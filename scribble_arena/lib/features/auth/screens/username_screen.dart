import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';

/// Username creation screen shown after first sign-in.
class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      context.go('${AppRoutes.avatar}?username=${Uri.encodeComponent(_controller.text.trim())}');
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
                  'Choose your\nusername',
                  style: AppTextStyles.displayMedium().copyWith(
                    height: 1.2,
                  ),
                ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0, duration: 600.ms),

                const SizedBox(height: 8),

                Text(
                  'This is how other players will see you',
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 48),

                // ─── Input ───
                Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.darkBorder,
                        width: 1,
                      ),
                      color: AppColors.darkSurfaceVariant,
                    ),
                    child: TextFormField(
                      controller: _controller,
                      autofocus: true,
                      maxLength: AppConstants.maxUsernameLength,
                      style: AppTextStyles.headlineMedium(),
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        hintText: 'Enter username...',
                        hintStyle: AppTextStyles.headlineMedium().copyWith(
                          color: AppColors.darkTextTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        counterText: '',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Icon(
                            Icons.alternate_email_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 48),
                      ),
                      validator: Validators.validateUsername,
                      onFieldSubmitted: (_) => _onContinue(),
                    ),
                  ),
                ).animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ─── Rules ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRule('3-16 characters'),
                      _buildRule('Letters, numbers, and underscores only'),
                      _buildRule('No offensive words'),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                const Spacer(),

                // ─── Continue Button ───
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue', style: AppTextStyles.buttonText()),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white),
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

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: AppColors.darkTextTertiary),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall()),
        ],
      ),
    );
  }
}
