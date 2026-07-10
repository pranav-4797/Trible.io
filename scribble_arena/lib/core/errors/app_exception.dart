/// Custom exception types for Scribble Arena.
/// Provides structured error handling across the app.

/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Authentication related errors
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.signInFailed([dynamic error]) => AuthException(
        message: 'Sign in failed. Please try again.',
        code: 'SIGN_IN_FAILED',
        originalError: error,
      );

  factory AuthException.signInCancelled() => const AuthException(
        message: 'Sign in was cancelled.',
        code: 'SIGN_IN_CANCELLED',
      );

  factory AuthException.userNotFound() => const AuthException(
        message: 'User account not found.',
        code: 'USER_NOT_FOUND',
      );

  factory AuthException.tokenExpired() => const AuthException(
        message: 'Session expired. Please sign in again.',
        code: 'TOKEN_EXPIRED',
      );

  factory AuthException.unauthorized() => const AuthException(
        message: 'You are not authorized to perform this action.',
        code: 'UNAUTHORIZED',
      );
}

/// Network and API errors
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection. Please check your network.',
        code: 'NO_CONNECTION',
      );

  factory NetworkException.timeout() => const NetworkException(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT',
      );

  factory NetworkException.serverError([int? statusCode]) => NetworkException(
        message: 'Server error. Please try again later.',
        code: 'SERVER_ERROR',
        statusCode: statusCode,
      );

  factory NetworkException.badRequest([String? detail]) => NetworkException(
        message: detail ?? 'Invalid request.',
        code: 'BAD_REQUEST',
        statusCode: 400,
      );

  factory NetworkException.notFound() => const NetworkException(
        message: 'Resource not found.',
        code: 'NOT_FOUND',
        statusCode: 404,
      );

  factory NetworkException.rateLimited() => const NetworkException(
        message: 'Too many requests. Please slow down.',
        code: 'RATE_LIMITED',
        statusCode: 429,
      );
}

/// Socket.IO connection errors
class SocketException extends AppException {
  const SocketException({
    required super.message,
    super.code = 'SOCKET_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory SocketException.connectionFailed() => const SocketException(
        message: 'Failed to connect to game server.',
        code: 'CONNECTION_FAILED',
      );

  factory SocketException.disconnected() => const SocketException(
        message: 'Disconnected from game server.',
        code: 'DISCONNECTED',
      );

  factory SocketException.reconnecting() => const SocketException(
        message: 'Reconnecting to game server...',
        code: 'RECONNECTING',
      );

  factory SocketException.reconnectFailed() => const SocketException(
        message: 'Failed to reconnect. Please rejoin the game.',
        code: 'RECONNECT_FAILED',
      );
}

/// Game logic errors
class GameException extends AppException {
  const GameException({
    required super.message,
    super.code = 'GAME_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory GameException.roomFull() => const GameException(
        message: 'This room is full.',
        code: 'ROOM_FULL',
      );

  factory GameException.roomNotFound() => const GameException(
        message: 'Room not found. It may have been closed.',
        code: 'ROOM_NOT_FOUND',
      );

  factory GameException.roomClosed() => const GameException(
        message: 'This room has been closed.',
        code: 'ROOM_CLOSED',
      );

  factory GameException.gameInProgress() => const GameException(
        message: 'A game is already in progress in this room.',
        code: 'GAME_IN_PROGRESS',
      );

  factory GameException.notHost() => const GameException(
        message: 'Only the host can perform this action.',
        code: 'NOT_HOST',
      );

  factory GameException.notEnoughPlayers() => const GameException(
        message: 'Not enough players to start the game.',
        code: 'NOT_ENOUGH_PLAYERS',
      );

  factory GameException.invalidWord() => const GameException(
        message: 'Invalid word selection.',
        code: 'INVALID_WORD',
      );

  factory GameException.alreadyGuessed() => const GameException(
        message: 'You already guessed the word correctly!',
        code: 'ALREADY_GUESSED',
      );

  factory GameException.cannotGuessOwnWord() => const GameException(
        message: 'You cannot guess your own word!',
        code: 'CANNOT_GUESS_OWN',
      );

  factory GameException.kicked() => const GameException(
        message: 'You have been kicked from the room.',
        code: 'KICKED',
      );
}

/// Storage and data errors
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.readFailed() => const StorageException(
        message: 'Failed to read data.',
        code: 'READ_FAILED',
      );

  factory StorageException.writeFailed() => const StorageException(
        message: 'Failed to save data.',
        code: 'WRITE_FAILED',
      );

  factory StorageException.deleteFailed() => const StorageException(
        message: 'Failed to delete data.',
        code: 'DELETE_FAILED',
      );
}
