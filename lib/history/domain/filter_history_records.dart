import 'package:apdeteksi/core/utils/date_formatter.dart';
import 'package:apdeteksi/history/domain/detection_record.dart';

class FilterHistoryRecords {
  const FilterHistoryRecords();

  List<DetectionRecord> call(
    List<DetectionRecord> records, {
    required HistoryFilter filter,
    DateTime? date,
  }) {
    final result = records.where((r) {
      final byStatus = switch (filter) {
        HistoryFilter.all => true,
        HistoryFilter.complete => r.isComplete,
        HistoryFilter.incomplete => !r.isComplete,
      };
      final byDate = date == null || DateFormatter.isSameDay(r.detectedAt, date);
      return byStatus && byDate;
    }).toList();
    result.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return result;
  }
}
