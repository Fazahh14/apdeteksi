import '../domain/statistics_summary.dart';
import '../domain/statistics_repository.dart';
import 'statistics_data_source.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsDataSource _dataSource;
  const StatisticsRepositoryImpl(this._dataSource);

  @override
  Future<StatisticsSummary> getStatistics(StatisticsRange range) =>
      _dataSource.fetchStatistics(range);
}
