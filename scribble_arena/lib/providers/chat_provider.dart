import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import '../providers/room_provider.dart';
import '../core/utils/logger.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final socketService = ref.read(socketServiceProvider);
  return ChatNotifier(socketService);
});

class ChatMessage {
  final String username;
  final String message;
  final String type; // 'chat' | 'guess' | 'correct' | 'close' | 'system'
  final DateTime timestamp;

  const ChatMessage({
    required this.username,
    required this.message,
    required this.type,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      username: map['username'] as String? ?? 'System',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'chat',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final SocketService _socketService;
  final AppLogger _logger = AppLogger('ChatNotifier');
  String? _typerName;

  ChatNotifier(this._socketService) : super([]) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.on('chat:message', (data) {
      if (data != null) {
        final msg = ChatMessage.fromMap(data as Map<String, dynamic>);
        state = [...state, msg];
      }
    });

    _socketService.on('chat:correct', (data) {
      if (data != null) {
        final username = data['username'] as String? ?? 'Someone';
        final pos = data['position'] as int? ?? 1;
        state = [
          ...state,
          ChatMessage(
            username: 'System',
            message: '$username guessed correctly! (#$pos)',
            type: 'correct',
            timestamp: DateTime.now(),
          ),
        ];
      }
    });

    _socketService.on('chat:close', (data) {
      state = [
        ...state,
        ChatMessage(
          username: 'System',
          message: 'You are close!',
          type: 'close',
          timestamp: DateTime.now(),
        ),
      ];
    });

    _socketService.on('chat:system', (data) {
      if (data != null) {
        state = [
          ...state,
          ChatMessage(
            username: 'System',
            message: data['message'] as String? ?? '',
            type: 'system',
            timestamp: DateTime.now(),
          ),
        ];
      }
    });

    _socketService.on('game:turn_start', (_) {
      // Clear chat messages for the new turn
      state = [];
    });
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
    _socketService.emit('chat:message', {'message': message});
  }

  void sendTyping() {
    _socketService.emit('chat:typing');
  }

  void sendReaction(String emoji) {
    _socketService.emit('chat:reaction', {'emoji': emoji});
  }
}
