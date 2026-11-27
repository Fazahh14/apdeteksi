import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/statistik/data/statistics_data_source.dart';
import 'package:apdeteksi/statistik/data/statistics_repository_impl.dart';
import 'package:apdeteksi/statistik/domain/statistics_summary.dart';
import 'package:apdeteksi/statistik/domain/statistics_repository.dart';
import 'package:apdeteksi/statistik/domain/get_statistics.dart';

// ---- Dependency injection ----
final statisticsDataSourceProvider = Provider<StatisticsDataSource>(
  (ref) => StatisticsMockDataSource(),
);

final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => StatisticsRepositoryImpl(ref.watch(statisticsDataSourceProvider)),
);

final getStatisticsProvider = Provider<GetStatistics>(
  (ref) => GetStatistics(ref.watch(statisticsRepositoryProvider)),
);

// ---- UI state ----
class StatisticsRangeNotifier extends Notifier<StatisticsRange> {
  @override
  StatisticsRange build() => StatisticsRange.week;

  void set(StatisticsRange range) => state = range;
}

final statisticsRangeProvider =
    NotifierProvider<StatisticsRangeNotifier, StatisticsRange>(
      StatisticsRangeNotifier.new,
    );

// ---- Data ----
final statisticsProvider = FutureProvider<StatisticsSummary>((ref) {
  final range = ref.watch(statisticsRangeProvider);
  return ref.watch(getStatisticsProvider)(range);
});
