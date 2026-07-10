import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class FriendModel {
  final String uid;
  final String username;
  final String avatar;
  final bool isOnline;
  final int level;

  const FriendModel({
    required this.uid,
    required this.username,
    required this.avatar,
    required this.isOnline,
    required this.level,
  });
}

class FriendsState {
  final List<FriendModel> friends;
  final bool isLoading;
  final String? error;

  const FriendsState({
    this.friends = const [],
    this.isLoading = false,
    this.error,
  });

  FriendsState copyWith({
    List<FriendModel>? friends,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  final authService = ref.read(authServiceProvider);
  return FriendsNotifier(authService);
});

class FriendsNotifier extends StateNotifier<FriendsState> {
  final AuthService _authService;

  FriendsNotifier(this._authService) : super(const FriendsState()) {
    loadFriends();
  }

  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        // Simple mock friend model that is consistent with the UI
        final mockFriends = [
          const FriendModel(uid: 'f1', username: 'GamerPro', avatar: '🦊', isOnline: true, level: 15),
          const FriendModel(uid: 'f2', username: 'ArtistX', avatar: '🐼', isOnline: true, level: 22),
          const FriendModel(uid: 'f3', username: 'SketchMaster', avatar: '🦁', isOnline: false, level: 8),
          const FriendModel(uid: 'f4', username: 'DrawKing', avatar: '🎭', isOnline: false, level: 31),
          const FriendModel(uid: 'f5', username: 'PaintWiz', avatar: '🤖', isOnline: true, level: 12),
        ];
        state = state.copyWith(friends: mockFriends, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'User profile not found');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addFriend(String username) async {
    // Add friend logic
    loadFriends();
  }
}
