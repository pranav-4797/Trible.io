import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import '../providers/room_provider.dart';
import '../core/utils/logger.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final socketService = ref.read(socketServiceProvider);
  return GameNotifier(socketService);
});

class GamePlayer {
  final String uid;
  final String username;
  final String avatar;
  final int score;
  final bool hasGuessedCorrectly;

  const GamePlayer({
    required this.uid,
    required this.username,
    required this.avatar,
    required this.score,
    this.hasGuessedCorrectly = false,
  });

  factory GamePlayer.fromMap(Map<String, dynamic> map) {
    return GamePlayer(
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? '',
      avatar: map['avatar'] as String? ?? '🎨',
      score: map['score'] as int? ?? 0,
      hasGuessedCorrectly: map['hasGuessedCorrectly'] as bool? ?? false,
    );
  }
}

class GameState {
  final bool isStarting;
  final bool isPlaying;
  final bool isChoosingWord;
  final bool isTurnOver;
  final bool isGameOver;
  final int countdown;
  final int timeRemaining;
  final int currentRound;
  final int totalRounds;
  final int currentTurn;
  final String? currentWord;
  final String? currentHint;
  final String? currentDrawerId;
  final String? currentDrawerName;
  final List<String> wordChoices;
  final List<GamePlayer> players;
  final Map<String, dynamic>? results;

  const GameState({
    this.isStarting = false,
    this.isPlaying = false,
    this.isChoosingWord = false,
    this.isTurnOver = false,
    this.isGameOver = false,
    this.countdown = 0,
    this.timeRemaining = 0,
    this.currentRound = 1,
    this.totalRounds = 3,
    this.currentTurn = 1,
    this.currentWord,
    this.currentHint,
    this.currentDrawerId,
    this.currentDrawerName,
    this.wordChoices = const [],
    this.players = const [],
    this.results,
  });

  GameState copyWith({
    bool? isStarting,
    bool? isPlaying,
    bool? isChoosingWord,
    bool? isTurnOver,
    bool? isGameOver,
    int? countdown,
    int? timeRemaining,
    int? currentRound,
    int? totalRounds,
    int? currentTurn,
    String? currentWord,
    String? currentHint,
    String? currentDrawerId,
    String? currentDrawerName,
    List<String>? wordChoices,
    List<GamePlayer>? players,
    Map<String, dynamic>? results,
  }) {
    return GameState(
      isStarting: isStarting ?? this.isStarting,
      isPlaying: isPlaying ?? this.isPlaying,
      isChoosingWord: isChoosingWord ?? this.isChoosingWord,
      isTurnOver: isTurnOver ?? this.isTurnOver,
      isGameOver: isGameOver ?? this.isGameOver,
      countdown: countdown ?? this.countdown,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      currentTurn: currentTurn ?? this.currentTurn,
      currentWord: currentWord ?? this.currentWord,
      currentHint: currentHint ?? this.currentHint,
      currentDrawerId: currentDrawerId ?? this.currentDrawerId,
      currentDrawerName: currentDrawerName ?? this.currentDrawerName,
      wordChoices: wordChoices ?? this.wordChoices,
      players: players ?? this.players,
      results: results ?? this.results,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final SocketService _socketService;
  final AppLogger _logger = AppLogger('GameNotifier');

  GameNotifier(this._socketService) : super(const GameState()) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.on('game:starting', (data) {
      _logger.info('Game starting...');
      if (data != null) {
        state = GameState(
          isStarting: true,
          countdown: data['countdown'] as int? ?? 3,
          totalRounds: data['totalRounds'] as int? ?? 3,
          players: (data['players'] as List<dynamic>?)
                  ?.map((p) => GamePlayer.fromMap(p as Map<String, dynamic>))
                  .toList() ??
              [],
        );
      }
    });

    _socketService.on('game:word_choices', (data) {
      _logger.info('Received word choices');
      if (data != null) {
        state = state.copyWith(
          isChoosingWord: true,
          wordChoices: List<String>.from(data['words'] ?? []),
          currentRound: data['round'] as int? ?? state.currentRound,
          currentTurn: data['turn'] as int? ?? state.currentTurn,
        );
      }
    });

    _socketService.on('game:turn_start', (data) {
      _logger.info('Turn starting...');
      if (data != null) {
        final isChoosing = data['isChoosingWord'] as bool? ?? false;
        state = state.copyWith(
          isPlaying: !isChoosing,
          isChoosingWord: isChoosing,
          isTurnOver: false,
          currentDrawerId: data['drawerUid'] as String?,
          currentDrawerName: data['drawerName'] as String?,
          currentWord: data['word'] as String?,
          currentHint: data['hint'] as String?,
          timeRemaining: data['timeLimit'] as int? ?? 80,
          currentRound: data['round'] as int? ?? state.currentRound,
          currentTurn: data['turn'] as int? ?? state.currentTurn,
        );
      }
    });

    _socketService.on('game:timer', (data) {
      if (data != null) {
        state = state.copyWith(
          timeRemaining: data['remaining'] as int? ?? 0,
        );
      }
    });

    _socketService.on('game:word_hint', (data) {
      if (data != null) {
        state = state.copyWith(
          currentHint: data['hint'] as String?,
        );
      }
    });

    _socketService.on('game:turn_end', (data) {
      _logger.info('Turn ended');
      if (data != null) {
        state = state.copyWith(
          isTurnOver: true,
          currentWord: data['word'] as String?,
        );
      }
    });

    _socketService.on('game:end', (data) {
      _logger.info('Game ended');
      if (data != null) {
        state = state.copyWith(
          isGameOver: true,
          isPlaying: false,
          results: data as Map<String, dynamic>,
        );
      }
    });

    _socketService.on('score:update', (data) {
      if (data != null && data['scores'] != null) {
        state = state.copyWith(
          players: (data['scores'] as List<dynamic>?)
                  ?.map((p) => GamePlayer.fromMap(p as Map<String, dynamic>))
                  .toList() ??
              [],
        );
      }
    });

    _socketService.on('game:rematch_accepted', (_) {
      state = const GameState();
    });
  }

  void chooseWord(int index) {
    _socketService.emit('game:word_chosen', {'wordIndex': index});
    state = state.copyWith(isChoosingWord: false);
  }

  void startGame() {
    _socketService.emit('game:start');
  }

  void requestRematch() {
    _socketService.emit('game:rematch');
  }
}
