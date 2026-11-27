import '../domain/statistics_summary.dart';
import 'statistics_model.dart';

abstract class StatisticsDataSource {
  Future<StatisticsModel> fetchStatistics(StatisticsRange range);
}

/// Data contoh. Ganti dengan implementasi asli.
class StatisticsMockDataSource implements StatisticsDataSource {
  @override
  Future<StatisticsModel> fetchStatistics(StatisticsRange range) async {
    await Future.delayed(const Duration(milliseconds: 300));

    List<Map<String, dynamic>> scores(Map<String, double> m) =>
        m.entries.map((e) => {'label': e.key, 'value': e.value}).toList();

    switch (range) {
      case StatisticsRange.week:
        return StatisticsModel.fromMap({
          'average_score': 83,
          'trend_percent': 4,
          'scores': scores({
            'Sen': 0.62,
            'Sel': 0.80,
            'Rab': 0.97,
            'Kam': 0.42,
            'Jum': 0.62,
            'Sab': 0.97,
            'Min': 0.80,
          }),
          'missed': [
            {'name': 'Sarung tangan', 'count': 24},
            {'name': 'Sepatu safety', 'count': 18},
            {'name': 'Kacamata', 'count': 12},
            {'name': 'Apron las', 'count': 6},
          ],
        });
      case StatisticsRange.month:
        return StatisticsModel.fromMap({
          'average_score': 79,
          'trend_percent': 2,
          'scores': scores({'M1': 0.70, 'M2': 0.76, 'M3': 0.82, 'M4': 0.83}),
          'missed': [
            {'name': 'Sarung tangan', 'count': 96},
            {'name': 'Sepatu safety', 'count': 71},
            {'name': 'Kacamata', 'count': 50},
            {'name': 'Apron las', 'count': 22},
          ],
        });
      case StatisticsRange.year:
        return StatisticsModel.fromMap({
          'average_score': 76,
          'trend_percent': 9,
          'scores': scores({
            'Jan': 0.60,
            'Feb': 0.64,
            'Mar': 0.68,
            'Apr': 0.70,
            'Mei': 0.72,
            'Jun': 0.74,
            'Jul': 0.76,
            'Agu': 0.78,
            'Sep': 0.80,
            'Okt': 0.82,
            'Nov': 0.83,
            'Des': 0.85,
          }),
          'missed': [
            {'name': 'Sarung tangan', 'count': 1100},
            {'name': 'Sepatu safety', 'count': 840},
            {'name': 'Kacamata', 'count': 610},
            {'name': 'Apron las', 'count': 260},
          ],
        });
    }
  }
}
