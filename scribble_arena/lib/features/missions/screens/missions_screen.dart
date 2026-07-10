import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/widgets/daily_mission_card.dart';

/// Daily missions screen with multiple mission cards.
class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final missions = [
      _Mission('Play 3 Games', 1, 3, 50, Icons.videogame_asset_rounded),
      _Mission('Guess 10 Words', 4, 10, 75, Icons.lightbulb_rounded),
      _Mission('Draw 5 Times', 2, 5, 60, Icons.brush_rounded),
      _Mission('Win 2 Matches', 0, 2, 100, Icons.emoji_events_rounded),
      _Mission('Score 1000 Points', 350, 1000, 80, Icons.star_rounded),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Missions')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final m = missions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DailyMissionCard(
              title: m.title,
              progress: m.progress,
              total: m.total,
              reward: m.reward,
              icon: m.icon,
            ),
          ).animate()
              .fadeIn(duration: 400.ms, delay: (index * 100).ms)
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

class _Mission {
  final String title;
  final int progress;
  final int total;
  final int reward;
  final IconData icon;

  _Mission(this.title, this.progress, this.total, this.reward, this.icon);
}
