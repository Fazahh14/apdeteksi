import 'statistics_summary.dart';
import 'statistics_repository.dart';

class GetStatistics {
  final StatisticsRepository _repository;
  const GetStatistics(this._repository);

  Future<StatisticsSummary> call(StatisticsRange range) =>
      _repository.getStatistics(range);
}
