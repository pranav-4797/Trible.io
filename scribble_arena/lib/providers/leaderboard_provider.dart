import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class LeaderboardEntry {
  final int rank;
  final String uid;
  final String username;
  final String avatar;
  final int level;
  final int xp;
  final int wins;
  final int coins;

  const LeaderboardEntry({
    required this.rank,
    required this.uid,
    required this.username,
    required this.avatar,
    required this.level,
    required this.xp,
    required this.wins,
    required this.coins,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      rank: map['rank'] as int? ?? 0,
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? '',
      avatar: map['avatar'] as String? ?? '🎨',
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      wins: map['wins'] as int? ?? 0,
      coins: map['coins'] as int? ?? 0,
    );
  }
}

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final authService = ref.read(authServiceProvider);
  return LeaderboardNotifier(authService);
});

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final AuthService _authService;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.defaultServerUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
    receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
  ));

  LeaderboardNotifier(this._authService) : super(const LeaderboardState());

  Future<void> fetchLeaderboard(String type) async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _authService.getIdToken();
      final response = await _dio.get(
        '/api/leaderboard',
        queryParameters: {'type': type},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      if (response.data != null && response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>?)
                ?.map((e) => LeaderboardEntry.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];
        state = state.copyWith(entries: list, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data?['error']?['message'] ?? 'Failed to load leaderboard',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
