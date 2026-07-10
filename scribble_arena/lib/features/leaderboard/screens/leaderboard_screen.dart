import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Leaderboard screen with Global/Weekly/Monthly tabs.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _mockPlayers = List.generate(20, (i) => _LeaderboardEntry(
    rank: i + 1,
    username: 'Player${i + 1}',
    avatar: ['🎨', '🦊', '🐼', '🦁', '🐸', '🎭', '🤖', '👾', '🦄', '🐲'][i % 10],
    score: 5000 - (i * 200) + (i * i),
    level: 50 - i,
  ));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboard(_mockPlayers, isDark),
          _buildLeaderboard(_mockPlayers.reversed.toList(), isDark),
          _buildLeaderboard(_mockPlayers, isDark),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(List<_LeaderboardEntry> entries, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntry(entry, isDark)
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildEntry(_LeaderboardEntry entry, bool isDark) {
    final isTop3 = entry.rank <= 3;
    final rankColors = [AppColors.rankGold, AppColors.rankSilver, AppColors.rankBronze];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop3
              ? rankColors[entry.rank - 1].withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: isTop3
                ? Text(
                    ['🥇', '🥈', '🥉'][entry.rank - 1],
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '#${entry.rank}',
                    style: AppTextStyles.labelMedium(isDark: isDark),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 10),
          Text(entry.avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.username, style: AppTextStyles.titleMedium(isDark: isDark)),
                Text('Level ${entry.level}', style: AppTextStyles.bodySmall(isDark: isDark)),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: AppTextStyles.gameScore(isDark: isDark).copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry {
  final int rank;
  final String username;
  final String avatar;
  final int score;
  final int level;

  _LeaderboardEntry({required this.rank, required this.username, required this.avatar, required this.score, required this.level});
}
