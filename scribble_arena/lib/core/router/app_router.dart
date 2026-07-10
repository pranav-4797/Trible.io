import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/username_screen.dart';
import '../../features/auth/screens/avatar_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/room/screens/create_room_screen.dart';
import '../../features/room/screens/join_room_screen.dart';
import '../../features/room/screens/lobby_screen.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/game/screens/results_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/shop/screens/shop_screen.dart';
import '../../features/missions/screens/missions_screen.dart';
import '../../features/achievements/screens/achievements_screen.dart';
import '../../features/friends/screens/friends_screen.dart';

/// App route paths
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String username = '/username';
  static const String avatar = '/avatar';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String createRoom = '/create-room';
  static const String joinRoom = '/join-room';
  static const String lobby = '/lobby';
  static const String game = '/game';
  static const String results = '/results';
  static const String leaderboard = '/leaderboard';
  static const String shop = '/shop';
  static const String missions = '/missions';
  static const String achievements = '/achievements';
  static const String friends = '/friends';
}

/// GoRouter configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      // ─── Auth Flow ───
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.username,
        name: 'username',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UsernameScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.avatar,
        name: 'avatar',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AvatarScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),

      // ─── Main App ───
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),

      // ─── Room Flow ───
      GoRoute(
        path: AppRoutes.createRoom,
        name: 'createRoom',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateRoomScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.joinRoom,
        name: 'joinRoom',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const JoinRoomScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.lobby,
        name: 'lobby',
        pageBuilder: (context, state) {
          final roomId = state.uri.queryParameters['roomId'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: LobbyScreen(roomId: roomId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      // ─── Game ───
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        pageBuilder: (context, state) {
          final roomId = state.uri.queryParameters['roomId'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: GameScreen(roomId: roomId),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        pageBuilder: (context, state) {
          final roomId = state.uri.queryParameters['roomId'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResultsScreen(roomId: roomId),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),

      // ─── Features ───
      GoRoute(
        path: AppRoutes.leaderboard,
        name: 'leaderboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LeaderboardScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.shop,
        name: 'shop',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShopScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.missions,
        name: 'missions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MissionsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        name: 'achievements',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AchievementsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.friends,
        name: 'friends',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FriendsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎨', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

// ─── Transition Builders ───

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeInOut));
  return SlideTransition(position: animation.drive(tween), child: child);
}

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeOutCubic));
  return SlideTransition(position: animation.drive(tween), child: child);
}
