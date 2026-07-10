import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';

class LevelProgress extends StatelessWidget {
  final double progress;
  final String avatar;
  final bool isDark;

  const LevelProgress({
    super.key,
    required this.progress,
    required this.avatar,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 65,
      lineWidth: 5,
      percent: progress,
      center: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: AppColors.primaryGradient),
        ),
        child: Center(
          child: Text(avatar, style: const TextStyle(fontSize: 52)),
        ),
      ),
      progressColor: AppColors.xpGold,
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
