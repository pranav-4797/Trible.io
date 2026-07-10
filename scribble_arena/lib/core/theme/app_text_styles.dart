import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Scribble Arena.
/// Uses Google Fonts Outfit for a modern gaming feel.
class AppTextStyles {
  AppTextStyles._();

  // ─── Display ───
  static TextStyle displayLarge({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle displayMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle displaySmall({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  // ─── Headline ───
  static TextStyle headlineLarge({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle headlineMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle headlineSmall({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  // ─── Title ───
  static TextStyle titleLarge({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle titleMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle titleSmall({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  // ─── Body ───
  static TextStyle bodyLarge({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodyMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static TextStyle bodySmall({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      );

  // ─── Label ───
  static TextStyle labelLarge({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle labelMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static TextStyle labelSmall({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      );

  // ─── Game Specific ───
  static TextStyle gameTimer({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.timerNormal,
      );

  static TextStyle gameTimerWarning({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.timerWarning,
      );

  static TextStyle gameWord({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 4,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle gameScore({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.neonGreen,
      );

  static TextStyle chatMessage({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle chatUsername({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle correctGuess({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.correctGuess,
      );

  static TextStyle wrongGuess({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.wrongGuess,
      );

  static TextStyle rankNumber({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.xpGold,
      );

  static TextStyle coinAmount({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.coinGold,
      );

  static TextStyle xpAmount({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.xpGold,
      );

  static TextStyle buttonText({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle roomCode({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: 8,
        color: AppColors.neonGreen,
      );
}
