import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Color palette strip for the drawing canvas.
class ColorPalette extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final bool isDark;

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.drawingColors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final color = AppColors.drawingColors[index];
          final isSelected = color.value == selectedColor.value;

          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isSelected ? 38 : 32,
              height: isSelected ? 38 : 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (color == Colors.white
                          ? AppColors.darkBorder
                          : Colors.transparent),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
          );
        },
      ),
    );
  }
}
