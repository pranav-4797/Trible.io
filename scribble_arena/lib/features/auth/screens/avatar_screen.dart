import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/errors/error_handler.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/avatar_picker.dart';

/// Avatar selection screen shown after username creation.
class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  String _selectedAvatar = AppConstants.defaultAvatars[0];
  bool _isCreating = false;

  Future<void> _onComplete() async {
    final uri = GoRouterState.of(context).uri;
    final username = uri.queryParameters['username'] ?? 'Player';

    setState(() => _isCreating = true);

    final success = await ref.read(authProvider.notifier).createProfile(
      username: username,
      avatar: _selectedAvatar,
    );

    if (mounted) {
      setState(() => _isCreating = false);
      if (success) {
        context.go(AppRoutes.home);
      } else {
        final error = ref.read(authProvider).error;
        if (error != null) {
          ErrorHandler.showError(context, Exception(error));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E21), Color(0xFF1A1040), Color(0xFF0A0E21)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // ─── Title ───
                Text(
                  'Pick your\navatar',
                  style: AppTextStyles.displayMedium().copyWith(height: 1.2),
                ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0, duration: 600.ms),

                const SizedBox(height: 8),

                Text(
                  'Express yourself with an emoji avatar',
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 32),

                // ─── Selected Avatar Preview ───
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Container(
                      key: ValueKey(_selectedAvatar),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _selectedAvatar,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                ).animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms),

                const SizedBox(height: 32),

                // ─── Avatar Grid ───
                Expanded(
                  child: AvatarPicker(
                    selectedAvatar: _selectedAvatar,
                    onAvatarSelected: (avatar) {
                      setState(() => _selectedAvatar = avatar);
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                ),

                // ─── Complete Button ───
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppColors.neonGreen.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Let\'s Play!',
                                style: AppTextStyles.buttonText().copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.rocket_launch_rounded,
                                  color: Colors.black),
                            ],
                          ),
                  ),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 800.ms)
                    .slideY(begin: 0.3, end: 0, duration: 500.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
