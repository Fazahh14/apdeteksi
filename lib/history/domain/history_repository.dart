import 'package:apdeteksi/history/domain/detection_record.dart';

abstract class HistoryRepository {
  Future<List<DetectionRecord>> getRecords();
}
