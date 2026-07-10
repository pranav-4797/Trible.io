import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import '../models/room_model.dart';
import '../core/constants/socket_events.dart';
import '../core/utils/logger.dart';

final socketServiceProvider = Provider<SocketService>((ref) => SocketService());

final roomProvider = StateNotifierProvider<RoomNotifier, RoomState>((ref) {
  final socketService = ref.read(socketServiceProvider);
  return RoomNotifier(socketService);
});

class RoomState {
  final RoomModel? currentRoom;
  final bool isLoading;
  final String? error;

  const RoomState({
    this.currentRoom,
    this.isLoading = false,
    this.error,
  });

  RoomState copyWith({
    RoomModel? currentRoom,
    bool? isLoading,
    String? error,
  }) {
    return RoomState(
      currentRoom: currentRoom ?? this.currentRoom,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RoomNotifier extends StateNotifier<RoomState> {
  final SocketService _socketService;
  final AppLogger _logger = AppLogger('RoomNotifier');

  RoomNotifier(this._socketService) : super(const RoomState()) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.on('lobby:update', (data) {
      _logger.info('Received lobby:update');
      if (data != null && data['room'] != null) {
        final room = RoomModel.fromMap(data['room'] as Map<String, dynamic>);
        state = state.copyWith(currentRoom: room, isLoading: false);
      }
    });

    _socketService.on('lobby:player_joined', (data) {
      _logger.info('Player joined the lobby');
      // Update local state if needed (lobby:update will also fire)
    });

    _socketService.on('lobby:player_left', (data) {
      _logger.info('Player left the lobby');
    });

    _socketService.on('room:settings_updated', (data) {
      _logger.info('Settings updated');
      if (data != null && data['room'] != null) {
        final room = RoomModel.fromMap(data['room'] as Map<String, dynamic>);
        state = state.copyWith(currentRoom: room);
      }
    });
  }

  Future<void> createRoom({
    bool isPrivate = false,
    int maxPlayers = 8,
    int rounds = 3,
    int drawTime = 80,
    String difficulty = 'medium',
  }) async {
    state = state.copyWith(isLoading: true);
    final settings = {
      'isPrivate': isPrivate,
      'maxPlayers': maxPlayers,
      'rounds': rounds,
      'drawTime': drawTime,
      'difficulty': difficulty,
    };

    _socketService.emitWithAck('room:create', settings, (response) {
      if (response != null && response['success'] == true) {
        final room = RoomModel.fromMap(response['room'] as Map<String, dynamic>);
        state = state.copyWith(currentRoom: room, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response?['error'] ?? 'Failed to create room',
        );
      }
    });
  }

  Future<void> joinRoom(String roomCode) async {
    state = state.copyWith(isLoading: true);
    _socketService.emitWithAck('room:join', {'roomCode': roomCode}, (response) {
      if (response != null && response['success'] == true) {
        final room = RoomModel.fromMap(response['room'] as Map<String, dynamic>);
        state = state.copyWith(currentRoom: room, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response?['error'] ?? 'Failed to join room',
        );
      }
    });
  }

  Future<void> leaveRoom() async {
    if (state.currentRoom == null) return;
    _socketService.emit('room:leave');
    state = const RoomState();
  }

  Future<void> toggleReady(bool isReady) async {
    _socketService.emit('lobby:player_ready', {'isReady': isReady});
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    _socketService.emit('room:settings', settings);
  }

  Future<void> kickPlayer(String targetUid) async {
    _socketService.emit('lobby:kick', {'targetUid': targetUid});
  }
}
