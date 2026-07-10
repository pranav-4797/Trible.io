import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/play_button.dart';
import '../widgets/stats_card.dart';
import '../widgets/daily_mission_card.dart';

/// Home screen — main dashboard with play options, stats, and navigation.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0E21), Color(0xFF131835)],
                )
              : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ─── Header ───
                _buildHeader(context, ref, user.username, user.avatar, user.coins, user.level, isDark),

                const SizedBox(height: 28),

                // ─── Play Buttons ───
                PlayButton(
                  label: 'Quick Play',
                  subtitle: 'Find a public match',
                  icon: Icons.bolt_rounded,
                  gradient: AppColors.primaryGradient,
                  onPressed: () => context.push(AppRoutes.joinRoom),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: PlayButton(
                        label: 'Create Room',
                        icon: Icons.add_circle_outline_rounded,
                        gradient: AppColors.accentGradient,
                        compact: true,
                        onPressed: () => context.push(AppRoutes.createRoom),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PlayButton(
                        label: 'Join Room',
                        icon: Icons.login_rounded,
                        gradient: AppColors.successGradient,
                        compact: true,
                        onPressed: () => context.push(AppRoutes.joinRoom),
                      ),
                    ),
                  ],
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 28),

                // ─── Stats ───
                Text(
                  'Your Stats',
                  style: AppTextStyles.headlineMedium(isDark: isDark),
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        label: 'Wins',
                        value: '${user.totalWins}',
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.xpGold,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        label: 'Games',
                        value: '${user.totalGames}',
                        icon: Icons.games_rounded,
                        color: AppColors.secondary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        label: 'Level',
                        value: '${user.level}',
                        icon: Icons.star_rounded,
                        color: AppColors.levelPurple,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 28),

                // ─── Daily Mission ───
                Text(
                  'Daily Mission',
                  style: AppTextStyles.headlineMedium(isDark: isDark),
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                const SizedBox(height: 12),

                const DailyMissionCard(
                  title: 'Play 3 Games',
                  progress: 1,
                  total: 3,
                  reward: 50,
                  icon: Icons.videogame_asset_rounded,
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 700.ms)
                    .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String username, String avatar, int coins, int level, bool isDark) {
    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 28)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name & Level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: AppTextStyles.titleLarge(isDark: isDark)),
              Text('Level $level', style: AppTextStyles.bodySmall(isDark: isDark)),
            ],
          ),
        ),
        // Coins
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.coinGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('$coins', style: AppTextStyles.coinAmount(isDark: isDark)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Theme toggle
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', true, isDark, () {}),
              _navItem(Icons.leaderboard_rounded, 'Ranks', false, isDark,
                  () => context.push(AppRoutes.leaderboard)),
              _navItem(Icons.shopping_bag_rounded, 'Shop', false, isDark,
                  () => context.push(AppRoutes.shop)),
              _navItem(Icons.people_rounded, 'Friends', false, isDark,
                  () => context.push(AppRoutes.friends)),
              _navItem(Icons.person_rounded, 'Profile', false, isDark,
                  () => context.push(AppRoutes.profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: active
                ? AppColors.primary
                : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? AppColors.primary
                  : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
