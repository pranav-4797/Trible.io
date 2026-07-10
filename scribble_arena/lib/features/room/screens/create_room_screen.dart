import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

/// Create room screen with game settings.
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  bool _isPrivate = false;
  int _maxPlayers = AppConstants.defaultMaxPlayers;
  int _rounds = AppConstants.defaultRounds;
  int _drawTime = AppConstants.defaultDrawTime;
  String _difficulty = AppConstants.difficultyMedium;
  bool _isCreating = false;

  void _createRoom() {
    setState(() => _isCreating = true);
    // Navigate to lobby — Socket.IO connection happens there
    context.push(
      '${AppRoutes.lobby}?roomId=new&isPrivate=$_isPrivate&maxPlayers=$_maxPlayers&rounds=$_rounds&drawTime=$_drawTime&difficulty=$_difficulty',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ─── Room Type ───
            _buildSectionTitle('Room Type', isDark).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    'Public',
                    Icons.public_rounded,
                    'Anyone can join',
                    !_isPrivate,
                    isDark,
                    () => setState(() => _isPrivate = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeCard(
                    'Private',
                    Icons.lock_rounded,
                    'Invite only',
                    _isPrivate,
                    isDark,
                    () => setState(() => _isPrivate = true),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 28),

            // ─── Players ───
            _buildSliderSetting(
              'Max Players',
              Icons.group_rounded,
              _maxPlayers.toDouble(),
              AppConstants.minPlayers.toDouble(),
              AppConstants.maxPlayersLimit.toDouble(),
              (v) => setState(() => _maxPlayers = v.round()),
              '${_maxPlayers} players',
              isDark,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 20),

            // ─── Rounds ───
            _buildSliderSetting(
              'Rounds',
              Icons.replay_rounded,
              _rounds.toDouble(),
              AppConstants.minRounds.toDouble(),
              AppConstants.maxRounds.toDouble(),
              (v) => setState(() => _rounds = v.round()),
              '$_rounds rounds',
              isDark,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: 20),

            // ─── Draw Time ───
            _buildSliderSetting(
              'Draw Time',
              Icons.timer_rounded,
              _drawTime.toDouble(),
              AppConstants.minDrawTime.toDouble(),
              AppConstants.maxDrawTime.toDouble(),
              (v) => setState(() => _drawTime = v.round()),
              '${_drawTime}s',
              isDark,
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

            const SizedBox(height: 28),

            // ─── Difficulty ───
            _buildSectionTitle('Difficulty', isDark).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            const SizedBox(height: 12),
            Row(
              children: AppConstants.difficulties.map((d) {
                final isSelected = d == _difficulty;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: d != AppConstants.difficulties.last ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkCard : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d[0].toUpperCase() + d.substring(1),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

            const SizedBox(height: 40),

            // ─── Create Button ───
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        'Create Room',
                        style: AppTextStyles.buttonText().copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title, style: AppTextStyles.headlineMedium(isDark: isDark));
  }

  Widget _buildTypeCard(String label, IconData icon, String desc, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary), size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.titleMedium(isDark: isDark).copyWith(
              color: isSelected ? AppColors.primary : null,
            )),
            const SizedBox(height: 4),
            Text(desc, style: AppTextStyles.bodySmall(isDark: isDark), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting(String label, IconData icon, double value, double min, double max, ValueChanged<double> onChanged, String display, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(label, style: AppTextStyles.titleMedium(isDark: isDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(display, style: AppTextStyles.labelMedium(isDark: isDark).copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
