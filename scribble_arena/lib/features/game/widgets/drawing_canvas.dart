import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/drawing_point_model.dart';

/// Custom drawing canvas with smooth stroke rendering.
/// Supports brush, eraser, undo, and clear operations.
class DrawingCanvas extends StatefulWidget {
  final Color color;
  final double brushSize;
  final String tool;
  final bool isDrawer;
  final bool isDark;

  const DrawingCanvas({
    super.key,
    required this.color,
    required this.brushSize,
    required this.tool,
    required this.isDrawer,
    required this.isDark,
  });

  @override
  DrawingCanvasState createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _undoneStrokes = [];
  DrawingStroke? _currentStroke;

  /// Undo the last stroke.
  void undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _undoneStrokes.add(_strokes.removeLast());
    });
  }

  /// Redo the last undone stroke.
  void redo() {
    if (_undoneStrokes.isEmpty) return;
    setState(() {
      _strokes.add(_undoneStrokes.removeLast());
    });
  }

  /// Clear the entire canvas.
  void clear() {
    setState(() {
      _undoneStrokes.clear();
      _strokes.clear();
    });
  }

  /// Add a remote stroke from another player.
  void addRemoteStroke(DrawingStroke stroke) {
    setState(() {
      _strokes.add(stroke);
    });
  }

  /// Handle remote undo.
  void remoteUndo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
    });
  }

  /// Handle remote clear.
  void remoteClear() {
    setState(() {
      _strokes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDark ? const Color(0xFF0D1117) : Colors.white,
      child: GestureDetector(
        onPanStart: widget.isDrawer ? _onPanStart : null,
        onPanUpdate: widget.isDrawer ? _onPanUpdate : null,
        onPanEnd: widget.isDrawer ? _onPanEnd : null,
        child: ClipRect(
          child: CustomPaint(
            painter: _CanvasPainter(
              strokes: _strokes,
              currentStroke: _currentStroke,
              backgroundColor: widget.isDark ? const Color(0xFF0D1117) : Colors.white,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final point = details.localPosition;
    _undoneStrokes.clear(); // Clear redo stack on new stroke
    _currentStroke = DrawingStroke(
      points: [point],
      color: widget.tool == 'eraser'
          ? (widget.isDark ? const Color(0xFF0D1117) : Colors.white)
          : widget.color,
      size: widget.tool == 'eraser' ? widget.brushSize * 3 : widget.brushSize,
      tool: widget.tool,
    );
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke == null) return;
    final point = details.localPosition;
    _currentStroke = _currentStroke!.copyWith(
      points: [..._currentStroke!.points, point],
    );
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke == null) return;
    _strokes.add(_currentStroke!);
    _currentStroke = null;
    setState(() {});
  }
}

/// Custom painter that renders all strokes with smooth lines.
class _CanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;
  final Color backgroundColor;

  _CanvasPainter({
    required this.strokes,
    this.currentStroke,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw all completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current (in-progress) stroke
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.size
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (stroke.tool == 'eraser') {
      paint.blendMode = BlendMode.srcOver;
    }

    if (stroke.points.length == 1) {
      // Single dot
      canvas.drawCircle(stroke.points.first, stroke.size / 2, paint..style = PaintingStyle.fill);
      return;
    }

    // Draw smooth path through points
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      // Use quadratic bezier for smoother lines
      if (i < stroke.points.length - 1) {
        final midX = (stroke.points[i].dx + stroke.points[i + 1].dx) / 2;
        final midY = (stroke.points[i].dy + stroke.points[i + 1].dy) / 2;
        path.quadraticBezierTo(
          stroke.points[i].dx,
          stroke.points[i].dy,
          midX,
          midY,
        );
      } else {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return oldDelegate.strokes.length != strokes.length ||
        oldDelegate.currentStroke != currentStroke;
  }
}
