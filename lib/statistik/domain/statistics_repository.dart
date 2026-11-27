import 'statistics_summary.dart';

abstract class StatisticsRepository {
  Future<StatisticsSummary> getStatistics(StatisticsRange range);
}
