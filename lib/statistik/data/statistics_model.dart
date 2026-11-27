import '../domain/statistics_summary.dart';

class StatisticsModel extends StatisticsSummary {
  const StatisticsModel({
    required super.averageScore,
    required super.trendPercent,
    required super.scores,
    required super.missed,
  });

  factory StatisticsModel.fromMap(Map<String, dynamic> map) {
    return StatisticsModel(
      averageScore: map['average_score'] as int,
      trendPercent: map['trend_percent'] as int,
      scores: (map['scores'] as List)
          .map(
            (e) => DailyScore(
              e['label'] as String,
              (e['value'] as num).toDouble(),
            ),
          )
          .toList(),
      missed: (map['missed'] as List)
          .map((e) => MissedPpe(e['name'] as String, e['count'] as int))
          .toList(),
    );
  }
}
