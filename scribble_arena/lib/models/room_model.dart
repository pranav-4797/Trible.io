import 'package:equatable/equatable.dart';

/// Room data model representing a game room.
class RoomModel extends Equatable {
  final String id;
  final String code;
  final String hostId;
  final String hostName;
  final bool isPrivate;
  final String status; // 'waiting', 'playing', 'finished'
  final int maxPlayers;
  final int rounds;
  final int drawTime;
  final String difficulty;
  final List<String> categories;
  final List<RoomPlayer> players;
  final DateTime createdAt;

  const RoomModel({
    required this.id,
    required this.code,
    required this.hostId,
    required this.hostName,
    this.isPrivate = false,
    this.status = 'waiting',
    this.maxPlayers = 8,
    this.rounds = 3,
    this.drawTime = 80,
    this.difficulty = 'medium',
    this.categories = const [],
    this.players = const [],
    required this.createdAt,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] as String? ?? '',
      code: map['code'] as String? ?? '',
      hostId: map['hostId'] as String? ?? '',
      hostName: map['hostName'] as String? ?? '',
      isPrivate: map['isPrivate'] as bool? ?? false,
      status: map['status'] as String? ?? 'waiting',
      maxPlayers: map['maxPlayers'] as int? ?? 8,
      rounds: map['rounds'] as int? ?? 3,
      drawTime: map['drawTime'] as int? ?? 80,
      difficulty: map['difficulty'] as String? ?? 'medium',
      categories: List<String>.from(map['categories'] ?? []),
      players: (map['players'] as List<dynamic>?)
              ?.map((p) => RoomPlayer.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'hostId': hostId,
      'hostName': hostName,
      'isPrivate': isPrivate,
      'status': status,
      'maxPlayers': maxPlayers,
      'rounds': rounds,
      'drawTime': drawTime,
      'difficulty': difficulty,
      'categories': categories,
      'players': players.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  RoomModel copyWith({
    String? id,
    String? code,
    String? hostId,
    String? hostName,
    bool? isPrivate,
    String? status,
    int? maxPlayers,
    int? rounds,
    int? drawTime,
    String? difficulty,
    List<String>? categories,
    List<RoomPlayer>? players,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      code: code ?? this.code,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      isPrivate: isPrivate ?? this.isPrivate,
      status: status ?? this.status,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      rounds: rounds ?? this.rounds,
      drawTime: drawTime ?? this.drawTime,
      difficulty: difficulty ?? this.difficulty,
      categories: categories ?? this.categories,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isFull => players.length >= maxPlayers;
  bool get canStart => players.length >= 2 && players.every((p) => p.isReady);

  @override
  List<Object?> get props => [id, code, status, players];
}

/// Player within a room.
class RoomPlayer extends Equatable {
  final String uid;
  final String username;
  final String avatar;
  final bool isReady;
  final bool isHost;
  final bool isConnected;
  final int score;

  const RoomPlayer({
    required this.uid,
    required this.username,
    required this.avatar,
    this.isReady = false,
    this.isHost = false,
    this.isConnected = true,
    this.score = 0,
  });

  factory RoomPlayer.fromMap(Map<String, dynamic> map) {
    return RoomPlayer(
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? '',
      avatar: map['avatar'] as String? ?? '🎨',
      isReady: map['isReady'] as bool? ?? false,
      isHost: map['isHost'] as bool? ?? false,
      isConnected: map['isConnected'] as bool? ?? true,
      score: map['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'avatar': avatar,
      'isReady': isReady,
      'isHost': isHost,
      'isConnected': isConnected,
      'score': score,
    };
  }

  RoomPlayer copyWith({
    String? uid,
    String? username,
    String? avatar,
    bool? isReady,
    bool? isHost,
    bool? isConnected,
    int? score,
  }) {
    return RoomPlayer(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      isReady: isReady ?? this.isReady,
      isHost: isHost ?? this.isHost,
      isConnected: isConnected ?? this.isConnected,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [uid, isReady, score, isConnected];
}
