import re
import os

filepath = r'lib\presentation\screens\rewards\rewards_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Extract GlassCard
glass_card_pattern = re.compile(r'// ==========================================\n// CUSTOM GLASS CARD COMPONENT\n// ==========================================\nclass _GlassCard extends StatelessWidget \{.*?\n\}', re.DOTALL)
glass_card_match = glass_card_pattern.search(content)
glass_card_code = glass_card_match.group(0).replace('_GlassCard', 'GlassCard')

glass_card_file = f"""import 'dart:ui';
import 'package:flutter/material.dart';

{glass_card_code}
"""
with open(r'lib\presentation\widgets\rewards\glass_card.dart', 'w', encoding='utf-8') as f:
    f.write(glass_card_file)

# 2. Extract Leaderboard Tab
leaderboard_pattern = re.compile(r'// ==========================================\n// LEADERBOARD TAB\n// ==========================================\n  Widget _buildLeaderboardTab\(RewardsService service, bool isDark\) \{(.*?)\n  \}\n\n  Widget _buildAvatarPlaceholder\(String displayName, bool isDark\) \{(.*?)\n  \}\n\n  Widget _buildCategorySelector\(String selectedCategory, Function\(String\) onSelect\) \{(.*?)\n  \}', re.DOTALL)

lb_match = leaderboard_pattern.search(content)
lb_body = lb_match.group(1)
avatar_body = lb_match.group(2)
cat_body = lb_match.group(3)

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
  Widget build(BuildContext context) {{{lb_body}
  }}

  Widget _buildAvatarPlaceholder(String displayName, bool isDark) {{{avatar_body}
  }}

  Widget _buildCategorySelector(BuildContext context, String selectedCategory, Function(String) onSelect) {{{cat_body}
  }}
}}
"""
# Fix the _buildCategorySelector call inside the body
lb_file = lb_file.replace('_leaderboardCategory', 'selectedCategory')
lb_file = lb_file.replace('_onCategoryChanged', 'onCategoryChanged')
lb_file = lb_file.replace('_buildCategorySelector(selectedCategory, onCategoryChanged)', '_buildCategorySelector(context, selectedCategory, onCategoryChanged)')

with open(r'lib\presentation\widgets\rewards\rewards_leaderboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(lb_file)

# 3. Extract Badges Tab
badges_pattern = re.compile(r'// ==========================================\n// BADGES TAB\n// ==========================================\n  Widget _buildBadgesTab\(Map<String, dynamic>\? status, bool isDark\) \{(.*?)\n  \}\n\n  void _showBadgeDetailSheet\(BuildContext context, _BadgeConfig badge, bool isEarned, bool isDark\) \{(.*?)\n  \}', re.DOTALL)

badges_match = badges_pattern.search(content)
badges_body = badges_match.group(1)
sheet_body = badges_match.group(2)

badge_config_pattern = re.compile(r'// ==========================================\n// BADGE CONFIGURATION DATA HOLDER\n// ==========================================\nclass _BadgeConfig \{.*?\}', re.DOTALL)
badge_config_match = badge_config_pattern.search(content)
badge_config_code = badge_config_match.group(0)

badges_file = f"""import 'dart:ui';
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
  Widget build(BuildContext context) {{{badges_body.replace('_GlassCard', 'GlassCard')}
  }}

  void _showBadgeDetailSheet(BuildContext context, _BadgeConfig badge, bool isEarned, bool isDark) {{{sheet_body}
  }}
}}

{badge_config_code}
"""
with open(r'lib\presentation\widgets\rewards\rewards_badges_tab.dart', 'w', encoding='utf-8') as f:
    f.write(badges_file)

# 4. Update Main File
# Remove blocks
content = content.replace(glass_card_match.group(0), '')
content = content.replace(lb_match.group(0), '')
content = content.replace(badges_match.group(0), '')
content = content.replace(badge_config_match.group(0), '')

# Replace usage in TabBarView
content = content.replace('_buildLeaderboardTab(rewardsService, isDark)', 'RewardsLeaderboardTab(service: rewardsService, isDark: isDark, selectedCategory: _leaderboardCategory, onCategoryChanged: _onCategoryChanged)')
content = content.replace('_buildBadgesTab(status, isDark)', 'RewardsBadgesTab(status: status, isDark: isDark)')

# Replace _GlassCard usage with GlassCard
content = content.replace('_GlassCard', 'GlassCard')

# Add imports
import_statements = """import '../../../core/services/auth_service.dart';
import '../../widgets/rewards/glass_card.dart';
import '../../widgets/rewards/rewards_leaderboard_tab.dart';
import '../../widgets/rewards/rewards_badges_tab.dart';"""

content = content.replace("import '../../../core/services/auth_service.dart';", import_statements)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Success')
