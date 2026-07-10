import '../constants/app_constants.dart';

/// Input validation utilities for Scribble Arena.
class Validators {
  Validators._();

  /// Validate a username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    if (trimmed.length > AppConstants.maxUsernameLength) {
      return 'Username must be at most ${AppConstants.maxUsernameLength} characters';
    }
    if (!RegExp(AppConstants.usernamePattern).hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    // Check for offensive words (basic filter)
    final lowerName = trimmed.toLowerCase();
    const blocked = ['admin', 'system', 'moderator', 'mod', 'null', 'undefined'];
    if (blocked.contains(lowerName)) {
      return 'This username is not allowed';
    }
    return null;
  }

  /// Validate a room code
  static String? validateRoomCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room code is required';
    }
    final trimmed = value.trim().toUpperCase();
    if (trimmed.length != AppConstants.roomCodeLength) {
      return 'Room code must be ${AppConstants.roomCodeLength} characters';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmed)) {
      return 'Room code can only contain letters and numbers';
    }
    return null;
  }

  /// Validate a chat message
  static String? validateChatMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Empty messages are just ignored, not an error
    }
    if (value.trim().length > AppConstants.maxChatMessageLength) {
      return 'Message is too long';
    }
    return null;
  }

  /// Validate a guess
  static String? validateGuess(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your guess';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Guess must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'Guess is too long';
    }
    return null;
  }

  /// Validate max players setting
  static String? validateMaxPlayers(int value) {
    if (value < AppConstants.minPlayers) {
      return 'Minimum ${AppConstants.minPlayers} players required';
    }
    if (value > AppConstants.maxPlayersLimit) {
      return 'Maximum ${AppConstants.maxPlayersLimit} players allowed';
    }
    return null;
  }

  /// Validate rounds setting
  static String? validateRounds(int value) {
    if (value < AppConstants.minRounds) {
      return 'Minimum ${AppConstants.minRounds} round required';
    }
    if (value > AppConstants.maxRounds) {
      return 'Maximum ${AppConstants.maxRounds} rounds allowed';
    }
    return null;
  }

  /// Validate draw time setting
  static String? validateDrawTime(int value) {
    if (value < AppConstants.minDrawTime) {
      return 'Minimum ${AppConstants.minDrawTime} seconds required';
    }
    if (value > AppConstants.maxDrawTime) {
      return 'Maximum ${AppConstants.maxDrawTime} seconds allowed';
    }
    return null;
  }

  /// Sanitize input by removing potentially harmful characters
  static String sanitize(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[<>"&]'), '') // Remove special chars
        .replaceAll("'", '') // Remove single quotes
        .trim();
  }

  /// Check if a string is a valid email
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if a guess is close to the actual word
  static bool isCloseGuess(String guess, String word) {
    final g = guess.toLowerCase().trim();
    final w = word.toLowerCase().trim();

    if (g == w) return false; // Exact match is not "close", it's correct

    // Check Levenshtein distance
    final distance = _levenshteinDistance(g, w);
    // Close if only 1-2 characters off
    return distance <= 2 && distance > 0;
  }

  /// Levenshtein distance calculation
  static int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> previousRow = List.generate(t.length + 1, (i) => i);
    List<int> currentRow = List.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      currentRow[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final insertCost = currentRow[j] + 1;
        final deleteCost = previousRow[j + 1] + 1;
        final replaceCost = previousRow[j] + (s[i] != t[j] ? 1 : 0);
        currentRow[j + 1] = [insertCost, deleteCost, replaceCost].reduce(
          (a, b) => a < b ? a : b,
        );
      }
      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[t.length];
  }
}
