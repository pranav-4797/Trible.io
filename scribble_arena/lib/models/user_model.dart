import 'package:equatable/equatable.dart';

/// User data model for Scribble Arena.
/// Represents a player's profile data stored in Firestore.
class UserModel extends Equatable {
  final String uid;
  final String username;
  final String avatar;
  final String email;
  final bool isGuest;
  final bool isOnline;
  final int coins;
  final int xp;
  final int level;
  final int totalWins;
  final int totalGames;
  final int totalCorrectGuesses;
  final int totalDrawings;
  final double guessAccuracy;
  final String rank;
  final String title;
  final String avatarFrame;
  final List<String> ownedBrushes;
  final List<String> ownedThemes;
  final List<String> ownedFrames;
  final List<String> ownedTitles;
  final List<String> friendIds;
  final List<String> achievements;
  final DateTime createdAt;
  final DateTime lastSeen;

  const UserModel({
    required this.uid,
    required this.username,
    required this.avatar,
    this.email = '',
    this.isGuest = false,
    this.isOnline = false,
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.totalWins = 0,
    this.totalGames = 0,
    this.totalCorrectGuesses = 0,
    this.totalDrawings = 0,
    this.guessAccuracy = 0.0,
    this.rank = 'Beginner',
    this.title = 'Newbie',
    this.avatarFrame = 'default',
    this.ownedBrushes = const ['basic'],
    this.ownedThemes = const ['default'],
    this.ownedFrames = const ['default'],
    this.ownedTitles = const ['Newbie'],
    this.friendIds = const [],
    this.achievements = const [],
    required this.createdAt,
    required this.lastSeen,
  });

  /// Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? 'Player',
      avatar: map['avatar'] as String? ?? '🎨',
      email: map['email'] as String? ?? '',
      isGuest: map['isGuest'] as bool? ?? false,
      isOnline: map['isOnline'] as bool? ?? false,
      coins: map['coins'] as int? ?? 0,
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      totalWins: map['totalWins'] as int? ?? 0,
      totalGames: map['totalGames'] as int? ?? 0,
      totalCorrectGuesses: map['totalCorrectGuesses'] as int? ?? 0,
      totalDrawings: map['totalDrawings'] as int? ?? 0,
      guessAccuracy: (map['guessAccuracy'] as num?)?.toDouble() ?? 0.0,
      rank: map['rank'] as String? ?? 'Beginner',
      title: map['title'] as String? ?? 'Newbie',
      avatarFrame: map['avatarFrame'] as String? ?? 'default',
      ownedBrushes: List<String>.from(map['ownedBrushes'] ?? ['basic']),
      ownedThemes: List<String>.from(map['ownedThemes'] ?? ['default']),
      ownedFrames: List<String>.from(map['ownedFrames'] ?? ['default']),
      ownedTitles: List<String>.from(map['ownedTitles'] ?? ['Newbie']),
      friendIds: List<String>.from(map['friendIds'] ?? []),
      achievements: List<String>.from(map['achievements'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      lastSeen: map['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'] as int)
          : DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'avatar': avatar,
      'email': email,
      'isGuest': isGuest,
      'isOnline': isOnline,
      'coins': coins,
      'xp': xp,
      'level': level,
      'totalWins': totalWins,
      'totalGames': totalGames,
      'totalCorrectGuesses': totalCorrectGuesses,
      'totalDrawings': totalDrawings,
      'guessAccuracy': guessAccuracy,
      'rank': rank,
      'title': title,
      'avatarFrame': avatarFrame,
      'ownedBrushes': ownedBrushes,
      'ownedThemes': ownedThemes,
      'ownedFrames': ownedFrames,
      'ownedTitles': ownedTitles,
      'friendIds': friendIds,
      'achievements': achievements,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  /// Copy with modifications
  UserModel copyWith({
    String? uid,
    String? username,
    String? avatar,
    String? email,
    bool? isGuest,
    bool? isOnline,
    int? coins,
    int? xp,
    int? level,
    int? totalWins,
    int? totalGames,
    int? totalCorrectGuesses,
    int? totalDrawings,
    double? guessAccuracy,
    String? rank,
    String? title,
    String? avatarFrame,
    List<String>? ownedBrushes,
    List<String>? ownedThemes,
    List<String>? ownedFrames,
    List<String>? ownedTitles,
    List<String>? friendIds,
    List<String>? achievements,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      isOnline: isOnline ?? this.isOnline,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      totalWins: totalWins ?? this.totalWins,
      totalGames: totalGames ?? this.totalGames,
      totalCorrectGuesses: totalCorrectGuesses ?? this.totalCorrectGuesses,
      totalDrawings: totalDrawings ?? this.totalDrawings,
      guessAccuracy: guessAccuracy ?? this.guessAccuracy,
      rank: rank ?? this.rank,
      title: title ?? this.title,
      avatarFrame: avatarFrame ?? this.avatarFrame,
      ownedBrushes: ownedBrushes ?? this.ownedBrushes,
      ownedThemes: ownedThemes ?? this.ownedThemes,
      ownedFrames: ownedFrames ?? this.ownedFrames,
      ownedTitles: ownedTitles ?? this.ownedTitles,
      friendIds: friendIds ?? this.friendIds,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// Calculate XP required for a given level
  static int xpForLevel(int level) {
    return (100 * (1.5 * (level - 1) + 1)).round();
  }

  /// Calculate level from total XP
  static int levelFromXp(int totalXp) {
    int level = 1;
    int requiredXp = 100;
    int accumulatedXp = 0;
    while (accumulatedXp + requiredXp <= totalXp) {
      accumulatedXp += requiredXp;
      level++;
      requiredXp = xpForLevel(level);
    }
    return level;
  }

  /// Get rank based on level
  static String rankFromLevel(int level) {
    if (level >= 50) return 'Legend';
    if (level >= 40) return 'Master';
    if (level >= 30) return 'Diamond';
    if (level >= 20) return 'Platinum';
    if (level >= 15) return 'Gold';
    if (level >= 10) return 'Silver';
    if (level >= 5) return 'Bronze';
    return 'Beginner';
  }

  /// Win rate percentage
  double get winRate {
    if (totalGames == 0) return 0.0;
    return (totalWins / totalGames) * 100;
  }

  @override
  List<Object?> get props => [uid, username, avatar, xp, level, coins];
}
