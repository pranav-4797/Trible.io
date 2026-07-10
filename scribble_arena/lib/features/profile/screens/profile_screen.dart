import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../widgets/level_progress.dart';
import '../widgets/stats_grid.dart';

/// Player profile screen with avatar, stats, and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final xpForCurrentLevel = UserModel.xpForLevel(user.level);
    final xpForPrevLevel = user.level > 1 ? UserModel.xpForLevel(user.level - 1) : 0;
    final xpProgress = xpForCurrentLevel > 0
        ? ((user.xp - xpForPrevLevel) / (xpForCurrentLevel - xpForPrevLevel)).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ─── Avatar & Level Ring ───
            LevelProgress(
              progress: xpProgress,
              avatar: user.avatar,
              isDark: isDark,
            ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),

            const SizedBox(height: 16),

            Text(user.username, style: AppTextStyles.displaySmall(isDark: isDark))
                .animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.goldGradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.rank,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: 8),

            Text(
              'Level ${user.level} • ${user.xp} XP',
              style: AppTextStyles.bodyMedium(isDark: isDark),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

            const SizedBox(height: 32),

            // ─── Stats Grid ───
            StatsGrid(
              totalGames: user.totalGames,
              totalWins: user.totalWins,
              winRate: user.winRate,
              coins: user.coins,
              correctGuesses: user.totalCorrectGuesses,
              totalDrawings: user.totalDrawings,
              isDark: isDark,
            ).animate()
                .fadeIn(duration: 500.ms, delay: 500.ms)
                .slideY(begin: 0.15, end: 0),

            const SizedBox(height: 24),

            // ─── Action Buttons ───
            _buildActionButton(
              icon: Icons.emoji_events_rounded,
              label: 'Achievements',
              color: AppColors.xpGold,
              isDark: isDark,
              onTap: () => context.push(AppRoutes.achievements),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

            const SizedBox(height: 8),

            _buildActionButton(
              icon: Icons.task_alt_rounded,
              label: 'Daily Missions',
              color: AppColors.neonGreen,
              isDark: isDark,
              onTap: () => context.push(AppRoutes.missions),
            ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

            const SizedBox(height: 8),

            _buildActionButton(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              color: AppColors.error,
              isDark: isDark,
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }



  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: AppTextStyles.titleMedium(isDark: isDark)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      ),
    );
  }
}
