import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/rewards_service.dart';

class RewardsLeaderboardTab extends StatelessWidget {
  final RewardsService service;
  final bool isDark;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const RewardsLeaderboardTab({
    super.key,
    required this.service,
    required this.isDark,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final list = service.leaderboard;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: _buildCategorySelector(
              context, selectedCategory, onCategoryChanged),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await service.fetchLeaderboard(selectedCategory);
            },
            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            child: list.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                          'No leaders in this category yet. Be the first!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = list[index] as Map<String, dynamic>;
                      final int rank = item['rank'] ?? (index + 1);
                      final String name = item['displayName'] ?? 'Anonymous';
                      final int points =
                          (item['ecoPoints'] as num?)?.toInt() ?? 0;
                      final String level = item['currentLevel'] ?? 'Recycler';
                      final String? city = item['city'];
                      final String? area = item['area'];

                      // Render Podium visual decoration for top 3
                      bool isPodium = rank <= 3;
                      Color? ringColor;
                      IconData? rankIcon;

                      if (rank == 1) {
                        ringColor = Colors.amber.shade600;
                        rankIcon = Icons.workspace_premium;
                      } else if (rank == 2) {
                        ringColor = Colors.grey.shade400;
                        rankIcon = Icons.emoji_events_outlined;
                      } else if (rank == 3) {
                        ringColor = Colors.brown.shade400;
                        rankIcon = Icons.emoji_events_outlined;
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPodium
                              ? (isDark
                                  ? ringColor!.withValues(alpha: 0.1)
                                  : ringColor!.withValues(alpha: 0.05))
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.black.withValues(alpha: 0.02)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPodium
                                ? ringColor!
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03)),
                            width: isPodium ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Rank Number/Medal
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPodium
                                    ? ringColor!.withValues(alpha: 0.2)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: isPodium
                                    ? Icon(rankIcon, color: ringColor, size: 20)
                                    : Text(
                                        '$rank',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // User Profile Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isPodium
                                    ? Border.all(color: ringColor!, width: 2)
                                    : null,
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade300,
                              ),
                              child: ClipOval(
                                child: item['profileImage'] != null
                                    ? Image.network(
                                        item['profileImage'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildAvatarPlaceholder(
                                                name, isDark),
                                      )
                                    : _buildAvatarPlaceholder(name, isDark),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Display details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    city != null ? '$area, $city' : level,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Points Counter
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$points PTS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.neonCyan
                                      : AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(String displayName, bool isDark) {
    return Center(
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, String selectedCategory,
      Function(String) onSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ['individuals', 'warehouses', 'companies'];
    final displayNames = {
      'individuals': 'Individuals',
      'warehouses': 'Warehouses',
      'companies': 'Companies'
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected
                      ? (isDark
                          ? AppColors.neonCyan.withValues(alpha: 0.2)
                          : AppColors.primaryGreen)
                      : Colors.transparent,
                  border: isSelected && isDark
                      ? Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.3))
                      : null,
                ),
                child: Text(
                  displayNames[cat]!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? AppColors.neonCyan : Colors.white)
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
