import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';

/// Join room screen — enter a room code to join.
class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isJoining = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _joinRoom() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isJoining = true);
      final code = _controller.text.trim().toUpperCase();
      context.push('${AppRoutes.lobby}?roomId=$code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Join Room')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // ─── Icon ───
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.login_rounded, color: AppColors.primary, size: 40),
            ).animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),

            const SizedBox(height: 24),

            Text(
              'Enter Room Code',
              style: AppTextStyles.headlineLarge(isDark: isDark),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              'Ask the host for the 6-character room code',
              style: AppTextStyles.bodyMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: 40),

            // ─── Code Input ───
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                autofocus: true,
                maxLength: AppConstants.roomCodeLength,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: AppTextStyles.roomCode(isDark: isDark).copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: AppTextStyles.roomCode().copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                validator: Validators.validateRoomCode,
                onFieldSubmitted: (_) => _joinRoom(),
              ),
            ).animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 32),

            // ─── Join Button ───
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isJoining ? null : _joinRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isJoining
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Join Room', style: AppTextStyles.buttonText()),
              ),
            ).animate()
                .fadeIn(duration: 500.ms, delay: 500.ms)
                .slideY(begin: 0.2, end: 0),

            const Spacer(),

            // ─── Quick Play ───
            TextButton.icon(
              onPressed: () {
                // Public matchmaking
              },
              icon: const Icon(Icons.bolt_rounded, color: AppColors.secondary),
              label: Text(
                'Or find a quick match',
                style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
