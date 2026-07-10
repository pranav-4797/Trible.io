import 'package:equatable/equatable.dart';

class MissionModel extends Equatable {
  final String id;
  final String title;
  final int progress;
  final int target;
  final int reward;
  final String type;
  final bool completed;
  final bool claimed;

  const MissionModel({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.reward,
    required this.type,
    this.completed = false,
    this.claimed = false,
  });

  factory MissionModel.fromMap(Map<String, dynamic> map) {
    return MissionModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      progress: map['progress'] as int? ?? 0,
      target: map['target'] as int? ?? 1,
      reward: map['reward'] as int? ?? 0,
      type: map['type'] as String? ?? 'games',
      completed: map['completed'] as bool? ?? false,
      claimed: map['claimed'] as bool? ?? false,
    );
  }

  MissionModel copyWith({
    String? id,
    String? title,
    int? progress,
    int? target,
    int? reward,
    String? type,
    bool? completed,
    bool? claimed,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      reward: reward ?? this.reward,
      type: type ?? this.type,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
    );
  }

  @override
  List<Object?> get props => [id, title, progress, target, completed];
}
