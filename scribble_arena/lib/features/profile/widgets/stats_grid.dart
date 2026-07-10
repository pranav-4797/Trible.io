import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StatsGrid extends StatelessWidget {
  final int totalGames;
  final int totalWins;
  final double winRate;
  final int coins;
  final int correctGuesses;
  final int totalDrawings;
  final bool isDark;

  const StatsGrid({
    super.key,
    required this.totalGames,
    required this.totalWins,
    required this.winRate,
    required this.coins,
    required this.correctGuesses,
    required this.totalDrawings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _statItem('Games', '$totalGames', Icons.games_rounded),
              _statItem('Wins', '$totalWins', Icons.emoji_events_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem('Win Rate', '${winRate.toStringAsFixed(1)}%', Icons.trending_up_rounded),
              _statItem('Coins', '$coins', Icons.monetization_on_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem('Correct Guesses', '$correctGuesses', Icons.check_circle_rounded),
              _statItem('Drawings', '$totalDrawings', Icons.brush_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.titleLarge(isDark: isDark)),
              Text(label, style: AppTextStyles.bodySmall(isDark: isDark)),
            ],
          ),
        ],
      ),
    );
  }
}
