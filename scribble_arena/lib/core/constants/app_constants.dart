/// App-wide constants for Scribble Arena.
class AppConstants {
  AppConstants._();

  // ─── App Info ───
  static const String appName = 'Trible';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // ─── Server ───
  static const String defaultServerUrl = 'https://trible-io.onrender.com'; // Render backend URL
  static const String productionServerUrl = 'https://trible-io.onrender.com';
  static const int socketReconnectDelay = 2000; // ms
  static const int socketMaxReconnectAttempts = 10;
  static const int socketTimeout = 10000; // ms
  static const int apiTimeout = 15000; // ms

  // ─── Game Settings Defaults ───
  static const int defaultMaxPlayers = 8;
  static const int minPlayers = 2;
  static const int maxPlayersLimit = 12;
  static const int defaultRounds = 3;
  static const int minRounds = 1;
  static const int maxRounds = 10;
  static const int defaultDrawTime = 80; // seconds
  static const int minDrawTime = 30;
  static const int maxDrawTime = 180;
  static const int defaultGuessTime = 10; // seconds after someone guesses
  static const int wordChoiceCount = 3;
  static const int wordChoiceTimeout = 15; // seconds to pick a word
  static const int hintInterval = 20; // seconds between hints
  static const int maxHints = 3;

  // ─── Scoring ───
  static const int maxGuessScore = 500;
  static const int minGuessScore = 100;
  static const int firstGuessBonus = 100;
  static const int drawerBaseScore = 50;
  static const int drawerBonusPerGuess = 25;
  static const int comboMultiplierStep = 50;
  static const int maxComboMultiplier = 5;
  static const int consecutiveWinBonus = 100;

  // ─── XP & Leveling ───
  static const int xpPerGame = 20;
  static const int xpPerWin = 50;
  static const int xpPerCorrectGuess = 10;
  static const int xpPerDrawRound = 15;
  static const int xpBaseForLevel = 100; // Level 1 requires 100 XP
  static const double xpLevelMultiplier = 1.5; // Each level requires 1.5x more

  // ─── Coins ───
  static const int coinsPerGame = 10;
  static const int coinsPerWin = 30;
  static const int coinsFirstGuess = 15;
  static const int coinsDailyLogin = 25;

  // ─── Room ───
  static const int roomCodeLength = 6;
  static const int maxRoomIdleTime = 300; // seconds before room auto-closes
  static const int lobbyCountdownTime = 5; // seconds countdown before game starts

  // ─── Chat ───
  static const int maxChatMessageLength = 100;
  static const int chatRateLimit = 3; // messages per second
  static const int maxChatHistory = 200;

  // ─── Drawing ───
  static const double defaultBrushSize = 5.0;
  static const double minBrushSize = 1.0;
  static const double maxBrushSize = 30.0;
  static const int maxUndoSteps = 30;
  static const int drawingBatchInterval = 50; // ms between drawing batches
  static const double canvasWidth = 800;
  static const double canvasHeight = 600;

  // ─── Validation ───
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 16;
  static const String usernamePattern = r'^[a-zA-Z0-9_]+$';

  // ─── Cache ───
  static const int maxCachedWords = 500;
  static const int wordCacheTtl = 86400; // 24 hours in seconds

  // ─── Anti-Cheat ───
  static const int maxGuessRate = 5; // max guesses per 3 seconds
  static const int minGuessInterval = 200; // ms between guesses
  static const int suspiciousScoreThreshold = 10000;

  // ─── UI ───
  static const double borderRadius = 14.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusSmall = 8.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 20.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // ─── Avatars ───
  static const List<String> defaultAvatars = [
    '🎨', '🖌️', '✏️', '🎭', '🦊', '🐱', '🐶', '🐼',
    '🦁', '🐸', '🦉', '🐧', '🎃', '👻', '🤖', '👾',
    '🦄', '🐲', '🦋', '🐝', '🌟', '⚡', '🔥', '💎',
    '🎪', '🎯', '🎲', '🎮', '🏆', '🎵', '🚀', '🌈',
  ];

  // ─── Difficulties ───
  static const String difficultyEasy = 'easy';
  static const String difficultyMedium = 'medium';
  static const String difficultyHard = 'hard';
  static const List<String> difficulties = [difficultyEasy, difficultyMedium, difficultyHard];

  // ─── Word Categories ───
  static const List<String> wordCategories = [
    'animals', 'food', 'sports', 'vehicles', 'household',
    'nature', 'professions', 'clothing', 'music', 'technology',
    'buildings', 'fantasy', 'ocean', 'space', 'art',
    'emotions', 'weather', 'tools', 'body', 'geography',
    'movies', 'toys',
  ];
}
