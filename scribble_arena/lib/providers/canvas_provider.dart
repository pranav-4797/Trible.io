import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import '../providers/room_provider.dart';
import '../models/drawing_point_model.dart';
import '../core/utils/logger.dart';

final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  final socketService = ref.read(socketServiceProvider);
  return CanvasNotifier(socketService);
});

class CanvasState {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  const CanvasState({
    this.strokes = const [],
    this.currentStroke,
  });

  CanvasState copyWith({
    List<DrawingStroke>? strokes,
    DrawingStroke? currentStroke,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      currentStroke: currentStroke,
    );
  }
}

class CanvasNotifier extends StateNotifier<CanvasState> {
  final SocketService _socketService;
  final AppLogger _logger = AppLogger('CanvasNotifier');

  CanvasNotifier(this._socketService) : super(const CanvasState()) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.on('draw:start', (data) {
      if (data != null) {
        final stroke = DrawingStroke.fromSocketData(data as Map<String, dynamic>);
        state = state.copyWith(strokes: [...state.strokes, stroke]);
      }
    });

    _socketService.on('draw:move', (data) {
      if (data != null && state.strokes.isNotEmpty) {
        final points = (data['points'] as List<dynamic>?)
                ?.map((p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()))
                .toList() ??
            [];
        final lastStroke = state.strokes.last;
        final updatedStroke = lastStroke.copyWith(
          points: [...lastStroke.points, ...points],
        );
        state = state.copyWith(
          strokes: [...state.strokes.sublist(0, state.strokes.length - 1), updatedStroke],
        );
      }
    });

    _socketService.on('draw:end', (_) {
      // Completed stroke
    });

    _socketService.on('draw:undo', (_) {
      if (state.strokes.isNotEmpty) {
        state = state.copyWith(
          strokes: state.strokes.sublist(0, state.strokes.length - 1),
        );
      }
    });

    _socketService.on('draw:clear', (_) {
      state = const CanvasState();
    });
  }

  void startStroke(Offset point, Color color, double size, String tool) {
    final stroke = DrawingStroke(
      points: [point],
      color: color,
      size: size,
      tool: tool,
    );
    state = state.copyWith(currentStroke: stroke);
    _socketService.emit('draw:start', stroke.toSocketData());
  }

  void updateStroke(Offset point) {
    if (state.currentStroke == null) return;
    final updated = state.currentStroke!.copyWith(
      points: [...state.currentStroke!.points, point],
    );
    state = state.copyWith(currentStroke: updated);

    // Optimize: send only last point
    _socketService.emit('draw:move', {
      'points': [
        {'x': point.dx, 'y': point.dy}
      ]
    });
  }

  void endStroke() {
    if (state.currentStroke == null) return;
    state = state.copyWith(
      strokes: [...state.strokes, state.currentStroke!],
    );
    _socketService.emit('draw:end');
  }

  void undo() {
    if (state.strokes.isEmpty) return;
    state = state.copyWith(
      strokes: state.strokes.sublist(0, state.strokes.length - 1),
    );
    _socketService.emit('draw:undo');
  }

  void clear() {
    state = const CanvasState();
    _socketService.emit('draw:clear');
  }
}
