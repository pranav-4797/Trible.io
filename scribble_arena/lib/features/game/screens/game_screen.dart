import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/color_palette.dart';
import '../widgets/timer_widget.dart';
import '../widgets/word_display.dart';
import '../widgets/chat_panel.dart';

/// Main game screen with drawing canvas, chat, and scoreboard.
class GameScreen extends ConsumerStatefulWidget {
  final String roomId;

  const GameScreen({super.key, required this.roomId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
  // Drawing state
  Color _selectedColor = Colors.black;
  double _brushSize = 5.0;
  String _tool = 'brush'; // 'brush', 'eraser'
  bool _showChat = false;
  bool _isDrawer = true; // Mock — will come from game state

  // Game state (mock)
  String _word = 'BUTTERFLY';
  String _hint = '_ _ _ _ _ _ _ _ _';
  int _timeRemaining = 60;
  int _currentRound = 1;
  int _totalRounds = 3;

  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar: Timer, Word, Round ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Round indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'R$_currentRound/$_totalRounds',
                      style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Word / Hint
                  Expanded(
                    child: WordDisplay(
                      word: _isDrawer ? _word : null,
                      hint: _isDrawer ? null : _hint,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Timer
                  TimerWidget(
                    remaining: _timeRemaining,
                    total: 80,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // ─── Canvas ───
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  DrawingCanvas(
                    key: _canvasKey,
                    color: _selectedColor,
                    brushSize: _brushSize,
                    tool: _tool,
                    isDrawer: _isDrawer,
                    isDark: isDark,
                  ),

                  // Scoreboard toggle (top right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _showChat = !_showChat),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkCard : AppColors.lightCard).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Icon(
                          _showChat ? Icons.brush_rounded : Icons.chat_bubble_outline_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  // Chat overlay
                  if (_showChat)
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: ChatPanel(
                        roomId: widget.roomId,
                        isDark: isDark,
                        isDrawer: _isDrawer,
                      ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.3, end: 0),
                    ),
                ],
              ),
            ),

            // ─── Drawing Tools (only for drawer) ───
            if (_isDrawer) ...[
              // Color Palette
              ColorPalette(
                selectedColor: _selectedColor,
                onColorSelected: (color) => setState(() => _selectedColor = color),
                isDark: isDark,
              ),

              // Toolbar
              DrawingToolbar(
                tool: _tool,
                brushSize: _brushSize,
                onToolChanged: (tool) => setState(() {
                  _tool = tool;
                  if (tool == 'eraser') {
                    _selectedColor = isDark ? AppColors.darkBackground : Colors.white;
                  }
                }),
                onBrushSizeChanged: (size) => setState(() => _brushSize = size),
                onUndo: () => _canvasKey.currentState?.undo(),
                onClear: () => _canvasKey.currentState?.clear(),
                isDark: isDark,
              ),
            ],

            // ─── Guess Input (for non-drawers) ───
            if (!_isDrawer)
              Container(
                padding: const EdgeInsets.all(12),
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
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type your guess...',
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
