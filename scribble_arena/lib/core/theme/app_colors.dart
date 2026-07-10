import 'dart:ui';

/// Scribble Arena color system.
/// Uses a vibrant, modern palette with neon accents for the gaming aesthetic.
class AppColors {
  AppColors._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9B8FFF);
  static const Color primaryDark = Color(0xFF4A3FC7);

  static const Color secondary = Color(0xFF00D2FF);
  static const Color secondaryLight = Color(0xFF66E5FF);
  static const Color secondaryDark = Color(0xFF00A3CC);

  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentLight = Color(0xFFFF9DC2);
  static const Color accentDark = Color(0xFFCC4470);

  // ─── Neon Accents (for game highlights) ───
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPink = Color(0xFFFF00AA);
  static const Color neonBlue = Color(0xFF00AAFF);
  static const Color neonYellow = Color(0xFFFFDD00);
  static const Color neonOrange = Color(0xFFFF8800);
  static const Color neonPurple = Color(0xFFAA00FF);

  // ─── Dark Theme Surface Colors ───
  static const Color darkBackground = Color(0xFF0A0E21);
  static const Color darkSurface = Color(0xFF131835);
  static const Color darkSurfaceVariant = Color(0xFF1C2248);
  static const Color darkCard = Color(0xFF1A1F3D);
  static const Color darkCardHover = Color(0xFF222752);
  static const Color darkBorder = Color(0xFF2A2F55);
  static const Color darkDivider = Color(0xFF1E2345);

  // ─── Light Theme Surface Colors ───
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F1F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHover = Color(0xFFF5F0FF);
  static const Color lightBorder = Color(0xFFE2E4ED);
  static const Color lightDivider = Color(0xFFEAECF2);

  // ─── Text Colors ───
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B5D0);
  static const Color darkTextTertiary = Color(0xFF6B7099);
  static const Color darkTextDisabled = Color(0xFF4A4F70);

  static const Color lightTextPrimary = Color(0xFF1A1F3D);
  static const Color lightTextSecondary = Color(0xFF5A5F80);
  static const Color lightTextTertiary = Color(0xFF8A8FAA);
  static const Color lightTextDisabled = Color(0xFFB0B5CC);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF00E676);
  static const Color successDark = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningDark = Color(0xFFFF8F00);
  static const Color error = Color(0xFFFF5252);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color info = Color(0xFF448AFF);
  static const Color infoDark = Color(0xFF2962FF);

  // ─── Game-Specific Colors ───
  static const Color correctGuess = Color(0xFF00E676);
  static const Color wrongGuess = Color(0xFFFF5252);
  static const Color closeGuess = Color(0xFFFFAB00);
  static const Color timerWarning = Color(0xFFFF5252);
  static const Color timerNormal = Color(0xFF00D2FF);
  static const Color xpGold = Color(0xFFFFD700);
  static const Color coinGold = Color(0xFFFFC107);
  static const Color levelPurple = Color(0xFF9B59B6);

  // ─── Rank Colors ───
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankBronze = Color(0xFFCD7F32);

  // ─── Drawing Palette ───
  static const List<Color> drawingColors = [
    Color(0xFF000000), // Black
    Color(0xFF424242), // Dark Gray
    Color(0xFF9E9E9E), // Gray
    Color(0xFFFFFFFF), // White
    Color(0xFFFF1744), // Red
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF9800), // Orange
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF8BC34A), // Light Green
    Color(0xFF4CAF50), // Green
    Color(0xFF009688), // Teal
    Color(0xFF00BCD4), // Cyan
    Color(0xFF2196F3), // Blue
    Color(0xFF3F51B5), // Indigo
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFFFF6D00), // Amber
    Color(0xFF00E5FF), // Light Cyan
    Color(0xFF76FF03), // Lime
    Color(0xFFD500F9), // Purple Accent
    Color(0xFFFF1744), // Red Accent
    Color(0xFF1DE9B6), // Teal Accent
    Color(0xFFF50057), // Pink Accent
  ];

  // ─── Gradient Presets ───
  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7),
    Color(0xFF00D2FF),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFFFC371),
  ];

  static const List<Color> successGradient = [
    Color(0xFF00E676),
    Color(0xFF00B0FF),
  ];

  static const List<Color> darkCardGradient = [
    Color(0xFF1A1F3D),
    Color(0xFF131835),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA000),
  ];

  static const List<Color> fireGradient = [
    Color(0xFFFF6B00),
    Color(0xFFFF0044),
  ];

  // ─── Avatar Background Colors ───
  static const List<Color> avatarColors = [
    Color(0xFF6C5CE7),
    Color(0xFF00D2FF),
    Color(0xFFFF6B9D),
    Color(0xFF00E676),
    Color(0xFFFFAB00),
    Color(0xFFFF5252),
    Color(0xFF9B59B6),
    Color(0xFF3498DB),
    Color(0xFFE67E22),
    Color(0xFF1ABC9C),
    Color(0xFFE74C3C),
    Color(0xFF2ECC71),
  ];
}
