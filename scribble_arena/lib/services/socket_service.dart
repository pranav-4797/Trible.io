import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/app_constants.dart';
import '../core/constants/socket_events.dart';
import '../core/utils/logger.dart';

/// Socket.IO client wrapper for realtime communication.
/// Handles connection, reconnection, and event management.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  final AppLogger _logger = AppLogger('SocketService');

  io.Socket? _socket;
  bool _isConnected = false;
  String? _token;
  int _reconnectAttempts = 0;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  /// Connect to the game server.
  void connect(String token, {String? serverUrl}) {
    _token = token;
    final url = serverUrl ?? AppConstants.defaultServerUrl;

    _logger.info('Connecting to $url');

    _socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': AppConstants.socketMaxReconnectAttempts,
      'reconnectionDelay': AppConstants.socketReconnectDelay,
      'timeout': AppConstants.socketTimeout,
      'auth': {'token': token},
    });

    _setupListeners();
  }

  void _setupListeners() {
    _socket?.on(SocketEvents.connect, (_) {
      _logger.info('Connected to server');
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);
    });

    _socket?.on(SocketEvents.disconnect, (reason) {
      _logger.warning('Disconnected: $reason');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket?.on(SocketEvents.connectError, (error) {
      _logger.error('Connection error: $error');
      _reconnectAttempts++;
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket?.on(SocketEvents.reconnect, (_) {
      _logger.info('Reconnected');
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);
    });
  }

  /// Emit an event to the server.
  void emit(String event, [dynamic data]) {
    if (_socket == null || !_isConnected) {
      _logger.warning('Cannot emit $event: not connected');
      return;
    }
    _socket!.emit(event, data);
  }

  /// Emit with acknowledgment.
  void emitWithAck(String event, dynamic data, Function(dynamic) ack) {
    if (_socket == null || !_isConnected) {
      _logger.warning('Cannot emit $event: not connected');
      return;
    }
    _socket!.emitWithAck(event, data, ack: ack);
  }

  /// Listen for an event from the server.
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Remove a specific event listener.
  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }

  /// Listen for an event once.
  void once(String event, Function(dynamic) handler) {
    _socket?.once(event, handler);
  }

  /// Disconnect from the server.
  void disconnect() {
    _logger.info('Disconnecting');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Reconnect to the server.
  void reconnect() {
    if (_token != null) {
      disconnect();
      connect(_token!);
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _connectionController.close();
  }
}
