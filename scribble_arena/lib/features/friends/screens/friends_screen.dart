import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Friends list screen with online status and invite functionality.
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final friends = [
      _Friend('GamerPro', '🦊', true, 15),
      _Friend('ArtistX', '🐼', true, 22),
      _Friend('SketchMaster', '🦁', false, 8),
      _Friend('DrawKing', '🎭', false, 31),
      _Friend('PaintWiz', '🤖', true, 12),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () {
              // Add friend dialog
            },
          ),
        ],
      ),
      body: friends.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👥', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No friends yet', style: AppTextStyles.headlineMedium(isDark: isDark)),
                  const SizedBox(height: 8),
                  Text('Add friends to play together!', style: AppTextStyles.bodyMedium(isDark: isDark)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final f = friends[index];
                return _buildFriendTile(f, isDark, context)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 80).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Widget _buildFriendTile(_Friend friend, bool isDark, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                ),
                child: Center(child: Text(friend.avatar, style: const TextStyle(fontSize: 26))),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: friend.isOnline ? AppColors.neonGreen : Colors.grey,
                    border: Border.all(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.username, style: AppTextStyles.titleMedium(isDark: isDark)),
                Text(
                  friend.isOnline ? 'Online' : 'Offline',
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    color: friend.isOnline ? AppColors.neonGreen : null,
                  ),
                ),
              ],
            ),
          ),
          Text('Lvl ${friend.level}', style: AppTextStyles.labelMedium(isDark: isDark)),
          const SizedBox(width: 8),
          if (friend.isOnline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Invite',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Friend {
  final String username;
  final String avatar;
  final bool isOnline;
  final int level;

  _Friend(this.username, this.avatar, this.isOnline, this.level);
}
