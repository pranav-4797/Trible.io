import 'dart:ui';
import 'package:equatable/equatable.dart';

/// Represents a single drawing stroke on the canvas.
class DrawingStroke extends Equatable {
  final List<Offset> points;
  final Color color;
  final double size;
  final String tool; // 'brush', 'eraser'

  const DrawingStroke({
    required this.points,
    required this.color,
    this.size = 5.0,
    this.tool = 'brush',
  });

  DrawingStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? size,
    String? tool,
  }) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      size: size ?? this.size,
      tool: tool ?? this.tool,
    );
  }

  /// Serialize for Socket.IO transmission
  Map<String, dynamic> toSocketData() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
      'size': size,
      'tool': tool,
    };
  }

  /// Deserialize from Socket.IO data
  factory DrawingStroke.fromSocketData(Map<String, dynamic> data) {
    final pointsList = (data['points'] as List<dynamic>?)
            ?.map((p) => Offset(
                  (p['x'] as num).toDouble(),
                  (p['y'] as num).toDouble(),
                ))
            .toList() ??
        [];

    final colorStr = data['color'] as String? ?? '#FF000000';
    final colorValue = int.parse(colorStr.replaceFirst('#', ''), radix: 16);

    return DrawingStroke(
      points: pointsList,
      color: Color(colorValue),
      size: (data['size'] as num?)?.toDouble() ?? 5.0,
      tool: data['tool'] as String? ?? 'brush',
    );
  }

  @override
  List<Object?> get props => [points.length, color, size, tool];
}

/// A single point in a drawing stroke with metadata.
class DrawingPoint {
  final double x;
  final double y;
  final String color;
  final double size;
  final String tool;

  const DrawingPoint({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    this.tool = 'brush',
  });

  Map<String, dynamic> toMap() => {
        'x': x,
        'y': y,
        'color': color,
        'size': size,
        'tool': tool,
      };

  factory DrawingPoint.fromMap(Map<String, dynamic> map) {
    return DrawingPoint(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      color: map['color'] as String? ?? '#FF000000',
      size: (map['size'] as num?)?.toDouble() ?? 5.0,
      tool: map['tool'] as String? ?? 'brush',
    );
  }
}
