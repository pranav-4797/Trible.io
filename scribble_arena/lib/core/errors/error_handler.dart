import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log_pkg;
import 'app_exception.dart';
import '../utils/logger.dart';

/// Global error handler for Scribble Arena.
/// Catches, logs, and presents errors to users with appropriate messages.
class ErrorHandler {
  static final AppLogger _logger = AppLogger('ErrorHandler');

  /// Initialize global error handling
  static void init() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.error(
        'Flutter Error: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
    };
  }

  /// Run a zone with error catching
  static R? runGuarded<R>(R Function() body, {Function(Object, StackTrace)? onError}) {
    try {
      return body();
    } catch (e, stack) {
      _logger.error('Guarded error', e, stack);
      onError?.call(e, stack);
      return null;
    }
  }

  /// Run an async operation with error catching
  static Future<T?> runAsync<T>(
    Future<T> Function() body, {
    Function(Object, StackTrace)? onError,
  }) async {
    try {
      return await body();
    } catch (e, stack) {
      _logger.error('Async error', e, stack);
      onError?.call(e, stack);
      return null;
    }
  }

  /// Get user-friendly message from an exception
  static String getUserMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (error is FormatException) {
      return 'Invalid data received.';
    }
    return 'Something went wrong. Please try again.';
  }

  /// Show a snackbar with error message
  static void showError(BuildContext context, Object error) {
    final message = getUserMessage(error);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show an info snackbar
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Determine if an error is retryable
  static bool isRetryable(Object error) {
    if (error is NetworkException) {
      return error.code == 'NO_CONNECTION' ||
          error.code == 'TIMEOUT' ||
          error.code == 'SERVER_ERROR';
    }
    if (error is SocketException) {
      return error.code == 'CONNECTION_FAILED' ||
          error.code == 'DISCONNECTED';
    }
    if (error is TimeoutException) return true;
    return false;
  }

  /// Retry an async operation with exponential backoff
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    Duration delay = initialDelay;
    Object? lastError;
    StackTrace? lastStack;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e, stack) {
        lastError = e;
        lastStack = stack;
        _logger.warning(
          'Retry attempt $attempt/$maxAttempts failed: $e',
        );

        if (attempt < maxAttempts && isRetryable(e)) {
          await Future.delayed(delay);
          delay *= backoffMultiplier;
        } else if (!isRetryable(e)) {
          rethrow;
        }
      }
    }

    _logger.error('All retry attempts failed', lastError, lastStack);
    throw lastError!;
  }
}
