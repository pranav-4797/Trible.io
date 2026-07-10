import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/player_stats_model.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final authService = ref.read(authServiceProvider);
  final authState = ref.watch(authProvider);
  return ProfileNotifier(authService, authState.user);
});

class ProfileState {
  final UserModel? user;
  final PlayerStatsModel? stats;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.user,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserModel? user,
    PlayerStatsModel? stats,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthService _authService;
  final UserModel? _currentUser;

  ProfileNotifier(this._authService, this._currentUser) : super(const ProfileState()) {
    if (_currentUser != null) {
      loadProfileData();
    }
  }

  Future<void> loadProfileData() async {
    if (_currentUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _authService.getUserProfile(_currentUser.uid);
      if (profile != null) {
        final stats = PlayerStatsModel(
          totalGames: profile.totalGames,
          totalWins: profile.totalWins,
          totalCorrectGuesses: profile.totalCorrectGuesses,
          totalDrawings: profile.totalDrawings,
          guessAccuracy: profile.guessAccuracy,
          winRate: profile.winRate,
        );
        state = state.copyWith(
          user: profile,
          stats: stats,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load profile data',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (state.user == null) return;
    try {
      await _authService.updateProfile(updates);
      await loadProfileData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateAvatar(String newAvatar) async {
    if (state.user == null) return;
    try {
      await _authService.updateProfile({'avatar': newAvatar});
      await loadProfileData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateUsername(String newUsername) async {
    if (state.user == null) return;
    try {
      await _authService.updateProfile({'username': newUsername});
      await loadProfileData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
