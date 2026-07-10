import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../core/utils/logger.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Auth state
enum AuthStatus { initial, loading, authenticated, unauthenticated, needsProfile, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider)),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final AppLogger _logger = AppLogger('AuthNotifier');

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        // Check if user has a profile
        final hasProfile = await _authService.hasProfile();
        if (hasProfile) {
          final profile = await _authService.getUserProfile();
          if (profile != null) {
            await _authService.setOnline();
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: profile,
            );
          } else {
            state = state.copyWith(status: AuthStatus.needsProfile);
          }
        } else {
          state = state.copyWith(status: AuthStatus.needsProfile);
        }
      }
    });
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signInWithGoogle();
      // Auth state listener will handle the rest
    } catch (e) {
      _logger.error('Google sign in error', e);
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Sign in as guest
  Future<void> signInAsGuest() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signInAsGuest();
      // Auth state listener will handle the rest
    } catch (e) {
      _logger.error('Guest sign in error', e);
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Create user profile
  Future<bool> createProfile({
    required String username,
    required String avatar,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // Check if username is taken
      final isTaken = await _authService.isUsernameTaken(username);
      if (isTaken) {
        state = state.copyWith(
          status: AuthStatus.needsProfile,
          error: 'Username is already taken',
        );
        return false;
      }

      final userModel = await _authService.createUserProfile(
        username: username,
        avatar: avatar,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userModel,
      );
      return true;
    } catch (e) {
      _logger.error('Create profile error', e);
      state = state.copyWith(
        status: AuthStatus.needsProfile,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      _logger.error('Sign out error', e);
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        state = state.copyWith(user: profile);
      }
    } catch (e) {
      _logger.error('Refresh profile error', e);
    }
  }

  /// Update profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await _authService.updateProfile(updates);
      await refreshProfile();
    } catch (e) {
      _logger.error('Update profile error', e);
    }
  }
}
