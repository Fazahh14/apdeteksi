import 'package:apdeteksi/history/domain/detection_record.dart';
import 'package:apdeteksi/history/domain/history_repository.dart';
import 'package:apdeteksi/history/data/history_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;
  const HistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<DetectionRecord>> getRecords() => _dataSource.fetchRecords();
}
