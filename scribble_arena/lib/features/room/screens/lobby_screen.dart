import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/errors/error_handler.dart';
import '../../../models/room_model.dart';
import '../widgets/player_tile.dart';

/// Waiting lobby screen showing players, room code, and ready state.
class LobbyScreen extends ConsumerStatefulWidget {
  final String roomId;

  const LobbyScreen({super.key, required this.roomId});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> with TickerProviderStateMixin {
  bool _isReady = false;

  // Mock data for UI demo — will be replaced by Socket.IO state
  late RoomModel _room;

  @override
  void initState() {
    super.initState();
    _room = RoomModel(
      id: widget.roomId,
      code: 'ABC123',
      hostId: 'user1',
      hostName: 'Player',
      players: [
        const RoomPlayer(uid: 'user1', username: 'Player', avatar: '🎨', isHost: true, isReady: true),
      ],
      createdAt: DateTime.now(),
    );
  }

  void _toggleReady() {
    setState(() => _isReady = !_isReady);
  }

  void _startGame() {
    context.go('${AppRoutes.game}?roomId=${widget.roomId}');
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _room.code));
    ErrorHandler.showSuccess(context, 'Room code copied!');
  }

  void _shareCode() {
    Share.share('Join my Trible room! Code: ${_room.code}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareCode,
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Room Code ───
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Room Code',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _copyCode,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_room.code, style: AppTextStyles.roomCode()),
                      const SizedBox(width: 12),
                      Icon(Icons.copy_rounded, color: AppColors.neonGreen, size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_room.players.length}/${_room.maxPlayers} players',
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.1, end: 0),

          // ─── Settings Summary ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              children: [
                _buildChip('${_room.rounds} Rounds', Icons.replay_rounded, isDark),
                _buildChip('${_room.drawTime}s Draw', Icons.timer_rounded, isDark),
                _buildChip(_room.difficulty[0].toUpperCase() + _room.difficulty.substring(1), Icons.speed_rounded, isDark),
                _buildChip(_room.isPrivate ? 'Private' : 'Public', Icons.lock_outline_rounded, isDark),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 20),

          // ─── Player List ───
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _room.players.length,
              itemBuilder: (context, index) {
                final player = _room.players[index];
                return PlayerTile(
                  player: player,
                  isCurrentUser: index == 0,
                  isDark: isDark,
                ).animate()
                    .fadeIn(duration: 400.ms, delay: (300 + index * 100).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),

          // ─── Bottom Actions ───
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                // Ready Toggle
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _toggleReady,
                      icon: Icon(
                        _isReady ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: _isReady ? AppColors.neonGreen : null,
                      ),
                      label: Text(_isReady ? 'Ready!' : 'Not Ready'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isReady ? AppColors.neonGreen : null,
                        side: BorderSide(
                          color: _isReady ? AppColors.neonGreen : AppColors.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Start Game (Host only)
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _room.players.length >= 2 ? _startGame : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Start Game',
                        style: AppTextStyles.buttonText().copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, bool isDark) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
