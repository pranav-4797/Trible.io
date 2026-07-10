import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_model.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

final missionProvider = StateNotifierProvider<MissionNotifier, MissionState>((ref) {
  final authService = ref.read(authServiceProvider);
  return MissionNotifier(authService);
});

class MissionState {
  final List<MissionModel> missions;
  final bool isLoading;
  final String? error;

  const MissionState({
    this.missions = const [],
    this.isLoading = false,
    this.error,
  });

  MissionState copyWith({
    List<MissionModel>? missions,
    bool? isLoading,
    String? error,
  }) {
    return MissionState(
      missions: missions ?? this.missions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MissionNotifier extends StateNotifier<MissionState> {
  final AuthService _authService;

  MissionNotifier(this._authService) : super(const MissionState()) {
    loadMissions();
  }

  Future<void> loadMissions() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        // Mock list matching database fallback or Firestore values
        final rawMissions = [
          const MissionModel(id: 'PLAY_GAMES', title: 'Play 3 Games', progress: 1, target: 3, reward: 50, type: 'games'),
          const MissionModel(id: 'GUESS_WORDS', title: 'Guess 10 Words', progress: 4, target: 10, reward: 75, type: 'guesses'),
          const MissionModel(id: 'DRAW_TIMES', title: 'Draw 5 Times', progress: 2, target: 5, reward: 60, type: 'drawings'),
          const MissionModel(id: 'WIN_MATCHES', title: 'Win 2 Matches', progress: 0, target: 2, reward: 100, type: 'wins'),
        ];
        state = state.copyWith(missions: rawMissions, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'User profile not found');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
