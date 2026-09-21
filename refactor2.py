import os

filepath = r'lib\presentation\screens\rewards\rewards_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

def get_block(start_marker, end_marker=None):
    start_idx = -1
    for i, line in enumerate(lines):
        if start_marker in line:
            start_idx = i
            break
    if start_idx == -1: return None
    
    # Find matching closing brace at same indent
    if end_marker:
        for i in range(start_idx + 1, len(lines)):
            if end_marker in lines[i]:
                return "".join(lines[start_idx:i+1]), start_idx, i+1
    else:
        # brace matching
        indent = len(lines[start_idx]) - len(lines[start_idx].lstrip())
        braces = 0
        started = False
        for i in range(start_idx, len(lines)):
            braces += lines[i].count('{')
            braces -= lines[i].count('}')
            if '{' in lines[i]: started = True
            if started and braces == 0:
                return "".join(lines[start_idx:i+1]), start_idx, i+1
    return None

# 1. GlassCard
glass_card, gc_s, gc_e = get_block('class _GlassCard extends StatelessWidget {')
glass_card = glass_card.replace('_GlassCard', 'GlassCard')

# 2. Leaderboard
lb, lb_s, lb_e = get_block('Widget _buildLeaderboardTab(RewardsService service, bool isDark) {')
ava, ava_s, ava_e = get_block('Widget _buildAvatarPlaceholder(String displayName, bool isDark) {')
cat, cat_s, cat_e = get_block('Widget _buildCategorySelector(String selectedCategory, Function(String) onSelect) {')

lb_file = f"""import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/rewards_service.dart';

class RewardsLeaderboardTab extends StatelessWidget {{
  final RewardsService service;
  final bool isDark;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const RewardsLeaderboardTab({{
    super.key,
    required this.service,
    required this.isDark,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }});

  @override
{lb}

{ava}

{cat}
}}
"""
lb_file = lb_file.replace('Widget _buildLeaderboardTab(RewardsService service, bool isDark)', 'Widget build(BuildContext context)')
lb_file = lb_file.replace('_leaderboardCategory', 'selectedCategory')
lb_file = lb_file.replace('_onCategoryChanged', 'onCategoryChanged')
lb_file = lb_file.replace('_buildCategorySelector(selectedCategory, onCategoryChanged)', '_buildCategorySelector(context, selectedCategory, onCategoryChanged)')
lb_file = lb_file.replace('Widget _buildCategorySelector(String selectedCategory, Function(String) onSelect)', 'Widget _buildCategorySelector(BuildContext context, String selectedCategory, Function(String) onSelect)')
lb_file = lb_file.replace('Theme.of(context)', 'Theme.of(context)')

# 3. Badges
bdg, bdg_s, bdg_e = get_block('Widget _buildBadgesTab(Map<String, dynamic>? status, bool isDark) {')
sheet, sheet_s, sheet_e = get_block('void _showBadgeDetailSheet(BuildContext context, _BadgeConfig badge, bool isEarned, bool isDark) {')
cfg, cfg_s, cfg_e = get_block('class _BadgeConfig {')

bdg_file = f"""import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'glass_card.dart';

class RewardsBadgesTab extends StatelessWidget {{
  final Map<String, dynamic>? status;
  final bool isDark;

  const RewardsBadgesTab({{
    super.key,
    required this.status,
    required this.isDark,
  }});

  @override
{bdg.replace('_GlassCard', 'GlassCard')}

{sheet}
}}

{cfg}
"""
bdg_file = bdg_file.replace('Widget _buildBadgesTab(Map<String, dynamic>? status, bool isDark)', 'Widget build(BuildContext context)')

# Writes
with open(r'lib\presentation\widgets\rewards\glass_card.dart', 'w', encoding='utf-8') as f:
    f.write(glass_card_file := f"""import 'dart:ui';
import 'package:flutter/material.dart';

{glass_card}
""")
with open(r'lib\presentation\widgets\rewards\rewards_leaderboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(lb_file)
with open(r'lib\presentation\widgets\rewards\rewards_badges_tab.dart', 'w', encoding='utf-8') as f:
    f.write(bdg_file)

# Update main file
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Instead of re matching, replace exactly the blocks we found
content = content.replace("".join(lines[gc_s:gc_e]), '')
content = content.replace("".join(lines[lb_s:lb_e]), '')
content = content.replace("".join(lines[ava_s:ava_e]), '')
content = content.replace("".join(lines[cat_s:cat_e]), '')
content = content.replace("".join(lines[bdg_s:bdg_e]), '')
content = content.replace("".join(lines[sheet_s:sheet_e]), '')
content = content.replace("".join(lines[cfg_s:cfg_e]), '')

# Extra clean up of headers
content = content.replace('// ==========================================\n// LEADERBOARD TAB\n// ==========================================\n', '')
content = content.replace('// ==========================================\n// BADGES TAB\n// ==========================================\n', '')
content = content.replace('// ==========================================\n// CUSTOM GLASS CARD COMPONENT\n// ==========================================\n', '')
content = content.replace('// ==========================================\n// BADGE CONFIGURATION DATA HOLDER\n// ==========================================\n', '')

# Usages
content = content.replace('_buildLeaderboardTab(rewardsService, isDark)', 'RewardsLeaderboardTab(service: rewardsService, isDark: isDark, selectedCategory: _leaderboardCategory, onCategoryChanged: _onCategoryChanged)')
content = content.replace('_buildBadgesTab(status, isDark)', 'RewardsBadgesTab(status: status, isDark: isDark)')
content = content.replace('_GlassCard', 'GlassCard')

# Imports
import_statements = """import '../../../core/services/auth_service.dart';
import '../../widgets/rewards/glass_card.dart';
import '../../widgets/rewards/rewards_leaderboard_tab.dart';
import '../../widgets/rewards/rewards_badges_tab.dart';"""

content = content.replace("import '../../../core/services/auth_service.dart';", import_statements)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Success')
