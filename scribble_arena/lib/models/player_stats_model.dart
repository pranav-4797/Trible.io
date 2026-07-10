import 'package:equatable/equatable.dart';

class PlayerStatsModel extends Equatable {
  final int totalGames;
  final int totalWins;
  final int totalCorrectGuesses;
  final int totalDrawings;
  final double guessAccuracy;
  final double winRate;

  const PlayerStatsModel({
    required this.totalGames,
    required this.totalWins,
    required this.totalCorrectGuesses,
    required this.totalDrawings,
    required this.guessAccuracy,
    required this.winRate,
  });

  factory PlayerStatsModel.fromMap(Map<String, dynamic> map) {
    final int games = map['totalGames'] as int? ?? 0;
    final int wins = map['totalWins'] as int? ?? 0;
    final double winRatePct = games == 0 ? 0.0 : (wins / games) * 100.0;

    return PlayerStatsModel(
      totalGames: games,
      totalWins: wins,
      totalCorrectGuesses: map['totalCorrectGuesses'] as int? ?? 0,
      totalDrawings: map['totalDrawings'] as int? ?? 0,
      guessAccuracy: (map['guessAccuracy'] as num?)?.toDouble() ?? 0.0,
      winRate: winRatePct,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalGames': totalGames,
      'totalWins': totalWins,
      'totalCorrectGuesses': totalCorrectGuesses,
      'totalDrawings': totalDrawings,
      'guessAccuracy': guessAccuracy,
    };
  }

  @override
  List<Object?> get props => [
        totalGames,
        totalWins,
        totalCorrectGuesses,
        totalDrawings,
        guessAccuracy,
        winRate,
      ];
}
