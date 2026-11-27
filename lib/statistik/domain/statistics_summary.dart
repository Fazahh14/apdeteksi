enum StatisticsRange { week, month, year }

class DailyScore {
  final String label;
  final double value; // 0..1
  const DailyScore(this.label, this.value);
}

class MissedPpe {
  final String name;
  final int count;
  const MissedPpe(this.name, this.count);
}

class StatisticsSummary {
  final int averageScore; // persen
  final int trendPercent; // bisa negatif
  final List<DailyScore> scores;
  final List<MissedPpe> missed;

  const StatisticsSummary({
    required this.averageScore,
    required this.trendPercent,
    required this.scores,
    required this.missed,
  });

  int get maxMissed =>
      missed.isEmpty ? 1 : missed.map((m) => m.count).reduce((a, b) => a > b ? a : b);
}
