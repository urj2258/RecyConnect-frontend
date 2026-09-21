import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'glass_card.dart';

class RewardsBadgesTab extends StatelessWidget {
  final Map<String, dynamic>? status;
  final bool isDark;

  const RewardsBadgesTab({
    super.key,
    required this.status,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = status;
    if (currentStatus == null) return const SizedBox.shrink();

    final userBadges = currentStatus['badges'] as List? ?? [];

    // System badges database configurations
    final systemBadges = [
      _BadgeConfig(
        name: 'First Sale Badge',
        description:
            'Complete your first successful recyclable waste materials sale.',
        icon: Icons.local_mall,
        color: Colors.orange,
      ),
      _BadgeConfig(
        name: 'Green Contributor',
        description:
            'Stay active and complete transactions this calendar month.',
        icon: Icons.eco,
        color: Colors.green,
      ),
      _BadgeConfig(
        name: 'Eco Hero',
        description:
            'Achieve an outstanding lifetime score of 1,000+ Eco Points.',
        icon: Icons.emoji_events,
        color: Colors.amber,
      ),
      _BadgeConfig(
        name: 'Trusted Seller',
        description:
            'Demonstrate top tier reliability with 100+ completed marketplace orders.',
        icon: Icons.verified_user,
        color: Colors.deepPurple,
      ),
      _BadgeConfig(
        name: 'Recycling Master',
        description:
            'Master the circular economy with 500+ total reward activity events.',
        icon: Icons.workspace_premium,
        color: Colors.teal,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: systemBadges.length,
      itemBuilder: (context, index) {
        final b = systemBadges[index];
        final isEarned =
            userBadges.any((element) => element['badgeName'] == b.name);

        return GestureDetector(
          onTap: () => _showBadgeDetailSheet(context, b, isEarned, isDark),
          child: GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Badge Avatar Shape
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEarned
                        ? b.color.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isEarned
                          ? b.color
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    b.icon,
                    size: 38,
                    color: isEarned
                        ? b.color
                        : (isDark ? Colors.white30 : Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  b.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isEarned
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white30 : Colors.grey.shade500),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Lock/Unlock Label
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEarned
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEarned ? Icons.check_circle : Icons.lock_outline,
                        size: 12,
                        color: isEarned
                            ? (isDark ? AppColors.neonGreen : AppColors.success)
                            : (isDark ? Colors.white30 : Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEarned ? 'Unlocked' : 'Locked',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isEarned
                              ? (isDark
                                  ? AppColors.neonGreen
                                  : AppColors.success)
                              : (isDark ? Colors.white30 : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDetailSheet(
      BuildContext context, _BadgeConfig badge, bool isEarned, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C33) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull-down handle bar
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Large Badge Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEarned
                      ? badge.color.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.05),
                  border: Border.all(
                    color: isEarned
                        ? badge.color
                        : (isDark ? Colors.white12 : Colors.black12),
                    width: 3,
                  ),
                  boxShadow: isEarned
                      ? [
                          BoxShadow(
                            color: badge.color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  badge.icon,
                  size: 58,
                  color: isEarned
                      ? badge.color
                      : (isDark ? Colors.white30 : Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 20),

              // Badge Name
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEarned
                        ? (isDark
                            ? AppColors.neonGreen
                            : AppColors.primaryGreen)
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEarned ? 'Collector Verified!' : 'Dismiss',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isEarned
                          ? (isDark ? const Color(0xFF070B19) : Colors.white)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeConfig {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  _BadgeConfig({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
