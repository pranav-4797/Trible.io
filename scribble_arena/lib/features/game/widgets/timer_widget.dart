import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Countdown timer display with color transitions.
class TimerWidget extends StatelessWidget {
  final int remaining;
  final int total;
  final bool isDark;

  const TimerWidget({
    super.key,
    required this.remaining,
    required this.total,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = remaining <= 10;
    final isCritical = remaining <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.error.withValues(alpha: 0.15)
            : isWarning
                ? AppColors.warning.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical
              ? AppColors.error.withValues(alpha: 0.5)
              : isWarning
                  ? AppColors.warning.withValues(alpha: 0.5)
                  : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: 18,
            color: isCritical
                ? AppColors.error
                : isWarning
                    ? AppColors.warning
                    : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '${remaining}s',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isCritical
                  ? AppColors.error
                  : isWarning
                      ? AppColors.warning
                      : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
