import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/errors/error_handler.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/login_button.dart';

/// Login screen with Google and Guest sign-in options.
/// Features animated branding, gradient background, and glassmorphic cards.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    // Navigate based on auth state
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      } else if (next.status == AuthStatus.needsProfile) {
        context.go(AppRoutes.username);
      } else if (next.status == AuthStatus.error && next.error != null) {
        ErrorHandler.showError(context, Exception(next.error));
      }
    });

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1A1040),
              Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.1),

                // ─── Logo & Title ───
                _buildLogo(context).animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideY(begin: -0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 12),

                Text(
                  'TRIBLE',
                  style: AppTextStyles.displayLarge().copyWith(
                    letterSpacing: 4,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
                  ),
                ).animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms),

                const SizedBox(height: 8),

                Text(
                  'Draw. Guess. Compete.',
                  style: AppTextStyles.bodyLarge().copyWith(
                    color: AppColors.darkTextSecondary,
                    letterSpacing: 2,
                  ),
                ).animate()
                    .fadeIn(duration: 600.ms, delay: 700.ms),

                SizedBox(height: size.height * 0.1),

                // ─── Login Buttons ───
                LoginButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  gradient: const [Color(0xFF4285F4), Color(0xFF34A853)],
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authProvider.notifier).signInWithGoogle(),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 900.ms)
                    .slideX(begin: -0.2, end: 0, duration: 500.ms),

                const SizedBox(height: 16),

                LoginButton(
                  label: 'Play as Guest',
                  icon: Icons.person_outline_rounded,
                  gradient: AppColors.primaryGradient,
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authProvider.notifier).signInAsGuest(),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 1100.ms)
                    .slideX(begin: 0.2, end: 0, duration: 500.ms),

                const SizedBox(height: 40),

                // ─── Footer ───
                Text(
                  'By continuing, you agree to our Terms of Service',
                  style: AppTextStyles.bodySmall().copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms, delay: 1300.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🎨',
          style: TextStyle(fontSize: 56),
        ),
      ),
    );
  }
}
