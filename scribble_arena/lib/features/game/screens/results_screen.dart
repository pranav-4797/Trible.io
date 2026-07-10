import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';

/// Game results screen with winner podium and player rankings.
class ResultsScreen extends ConsumerWidget {
  final String roomId;

  const ResultsScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock results — will come from game state
    final players = [
      _PlayerResult('Player1', '🎨', 1450, 1),
      _PlayerResult('Player2', '🦊', 1200, 2),
      _PlayerResult('Player3', '🐼', 900, 3),
      _PlayerResult('Player4', '🦁', 650, 4),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0E21), Color(0xFF1A1040), Color(0xFF0A0E21)],
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ─── Title ───
              Text(
                '🏆 Game Over!',
                style: AppTextStyles.displayMedium(isDark: isDark),
              ).animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),

              const SizedBox(height: 32),

              // ─── Winner Podium ───
              _buildPodium(players, isDark),

              const SizedBox(height: 24),

              // ─── Full Rankings ───
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final p = players[index];
                    return _buildRankingTile(p, isDark)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (600 + index * 100).ms)
                        .slideX(begin: 0.15, end: 0);
                  },
                ),
              ),

              // ─── Action Buttons ───
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.home),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Home'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Rematch
                          context.go('${AppRoutes.lobby}?roomId=$roomId');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Rematch', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<_PlayerResult> players, bool isDark) {
    if (players.length < 3) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        _buildPodiumColumn(players[1], 100, AppColors.rankSilver, isDark)
            .animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(width: 8),
        // 1st place
        _buildPodiumColumn(players[0], 130, AppColors.rankGold, isDark)
            .animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(width: 8),
        // 3rd place
        _buildPodiumColumn(players[2], 80, AppColors.rankBronze, isDark)
            .animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildPodiumColumn(_PlayerResult player, double height, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(player.avatar, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 4),
        Text(player.username, style: AppTextStyles.titleSmall(isDark: isDark)),
        Text('${player.score}', style: AppTextStyles.gameScore(isDark: isDark)),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.5)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '#${player.rank}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingTile(_PlayerResult player, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: player.rank == 1
              ? AppColors.rankGold.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player.rank <= 3
                  ? [AppColors.rankGold, AppColors.rankSilver, AppColors.rankBronze][player.rank - 1].withValues(alpha: 0.2)
                  : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
            ),
            child: Center(
              child: Text(
                '#${player.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: player.rank <= 3
                      ? [AppColors.rankGold, AppColors.rankSilver, AppColors.rankBronze][player.rank - 1]
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(player.avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(player.username, style: AppTextStyles.titleMedium(isDark: isDark)),
          ),
          Text(
            '${player.score}',
            style: AppTextStyles.gameScore(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _PlayerResult {
  final String username;
  final String avatar;
  final int score;
  final int rank;

  _PlayerResult(this.username, this.avatar, this.score, this.rank);
}
