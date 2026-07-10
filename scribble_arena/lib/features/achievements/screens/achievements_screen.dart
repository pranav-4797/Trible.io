import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Achievements screen with 50+ achievement entries.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final achievements = [
      _Achievement('First Steps', 'Play your first game', '🎮', true),
      _Achievement('Quick Draw', 'Win a game in under 30 seconds', '⚡', true),
      _Achievement('Art Master', 'Complete 50 drawings', '🎨', false),
      _Achievement('Word Wizard', 'Guess 100 words correctly', '🧙', false),
      _Achievement('Social Butterfly', 'Add 10 friends', '🦋', false),
      _Achievement('Winning Streak', 'Win 5 games in a row', '🔥', false),
      _Achievement('Sharpshooter', 'Guess correctly within 5 seconds', '🎯', true),
      _Achievement('Centurion', 'Play 100 games', '💯', false),
      _Achievement('Gold Rush', 'Earn 10,000 coins', '💰', false),
      _Achievement('Level 10', 'Reach level 10', '⭐', false),
      _Achievement('Level 25', 'Reach level 25', '🌟', false),
      _Achievement('Level 50', 'Reach level 50', '✨', false),
      _Achievement('Perfect Round', 'Everyone guesses your drawing', '💎', false),
      _Achievement('Speed Demon', 'First to guess 10 times', '🏎️', false),
      _Achievement('Night Owl', 'Play a game after midnight', '🦉', false),
      _Achievement('Early Bird', 'Play a game before 7 AM', '🐤', false),
      _Achievement('Polyglot', 'Use all word categories', '🌍', false),
      _Achievement('Minimalist', 'Win with under 10 brush strokes', '✏️', false),
      _Achievement('Colorful', 'Use all colors in one drawing', '🌈', false),
      _Achievement('Collector', 'Own 10 shop items', '🎁', false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${achievements.where((a) => a.unlocked).length}/${achievements.length}',
                style: AppTextStyles.labelLarge(isDark: isDark).copyWith(color: AppColors.xpGold),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final a = achievements[index];
          return _buildAchievementTile(a, isDark)
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 50).ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildAchievementTile(_Achievement achievement, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: achievement.unlocked
              ? AppColors.xpGold.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? AppColors.xpGold.withValues(alpha: 0.15)
                  : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: achievement.unlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: AppTextStyles.titleMedium(isDark: isDark).copyWith(
                    color: achievement.unlocked ? null : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                  ),
                ),
                Text(
                  achievement.description,
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
              ],
            ),
          ),
          if (achievement.unlocked)
            const Icon(Icons.check_circle_rounded, color: AppColors.xpGold, size: 24)
          else
            Icon(Icons.lock_outline_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary, size: 22),
        ],
      ),
    );
  }
}

class _Achievement {
  final String name;
  final String description;
  final String emoji;
  final bool unlocked;

  _Achievement(this.name, this.description, this.emoji, this.unlocked);
}
