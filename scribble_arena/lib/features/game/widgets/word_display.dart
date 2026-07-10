import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Word display showing either the full word (for drawer) or hint (for guessers).
class WordDisplay extends StatelessWidget {
  final String? word;
  final String? hint;
  final bool isDark;

  const WordDisplay({
    super.key,
    this.word,
    this.hint,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    if (word != null) {
      // Drawer sees the full word
      return Center(
        child: Text(
          word!.toUpperCase(),
          style: AppTextStyles.headlineMedium(isDark: isDark).copyWith(
            letterSpacing: 2,
            color: AppColors.neonGreen,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (hint != null) {
      // Guessers see the hint with underscores
      return Center(
        child: Text(
          hint!.split('').join(' '),
          style: AppTextStyles.headlineMedium(isDark: isDark).copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Center(
      child: Text(
        'Waiting...',
        style: AppTextStyles.bodyMedium(isDark: isDark),
      ),
    );
  }
}
