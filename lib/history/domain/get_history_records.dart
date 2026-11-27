import 'package:apdeteksi/history/domain/detection_record.dart';
import 'package:apdeteksi/history/domain/history_repository.dart';

class GetHistoryRecords {
  final HistoryRepository _repository;
  const GetHistoryRecords(this._repository);

  Future<List<DetectionRecord>> call() => _repository.getRecords();
}
