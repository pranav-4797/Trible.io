import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Grid of emoji avatars for profile creation.
class AvatarPicker extends StatelessWidget {
  final String selectedAvatar;
  final ValueChanged<String> onAvatarSelected;

  const AvatarPicker({
    super.key,
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: AppConstants.defaultAvatars.length,
      itemBuilder: (context, index) {
        final avatar = AppConstants.defaultAvatars[index];
        final isSelected = avatar == selectedAvatar;

        return GestureDetector(
          onTap: () => onAvatarSelected(avatar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.darkBorder,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(fontSize: isSelected ? 32 : 28),
              ),
            ),
          ),
        );
      },
    );
  }
}
