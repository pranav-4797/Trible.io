import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Drawing toolbar with tool selection, brush size, undo, and clear.
class DrawingToolbar extends StatelessWidget {
  final String tool;
  final double brushSize;
  final ValueChanged<String> onToolChanged;
  final ValueChanged<double> onBrushSizeChanged;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final bool isDark;

  const DrawingToolbar({
    super.key,
    required this.tool,
    required this.brushSize,
    required this.onToolChanged,
    required this.onBrushSizeChanged,
    required this.onUndo,
    required this.onClear,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Brush
            _buildToolButton(
              Icons.brush_rounded,
              'brush',
              'Brush',
            ),
            const SizedBox(width: 4),
            // Eraser
            _buildToolButton(
              Icons.auto_fix_high_rounded,
              'eraser',
              'Eraser',
            ),
            const SizedBox(width: 8),

            // Brush Size Slider
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: brushSize,
                  min: AppConstants.minBrushSize,
                  max: AppConstants.maxBrushSize,
                  onChanged: onBrushSizeChanged,
                ),
              ),
            ),

            // Brush size preview
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Container(
                width: brushSize.clamp(4, 24),
                height: brushSize.clamp(4, 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Undo
            _buildActionButton(Icons.undo_rounded, onUndo, 'Undo'),
            const SizedBox(width: 4),
            // Clear
            _buildActionButton(Icons.delete_outline_rounded, onClear, 'Clear'),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String toolName, String tooltip) {
    final isSelected = tool == toolName;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => onToolChanged(toolName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}
