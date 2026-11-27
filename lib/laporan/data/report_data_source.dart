import 'package:apdeteksi/laporan/domain/report.dart';
import 'package:apdeteksi/laporan/data/report_model.dart';

abstract class ReportDataSource {
  Future<ReportModel> fetchReport(ReportRange range);
  Future<bool> exportReport(ExportType type, ReportRange range);
}

/// Data contoh. Ganti dengan implementasi asli.
class ReportMockDataSource implements ReportDataSource {
  @override
  Future<ReportModel> fetchReport(ReportRange range) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    DateTime ago(int d) => today.subtract(Duration(days: d));

    // (checked, complete) per hari, dari hari ini ke belakang.
    final data = switch (range) {
      ReportRange.daily => [(42, 36)],
      ReportRange.week => [(42, 36), (40, 34), (45, 36), (38, 31)],
      ReportRange.month => [
          (42, 36), (40, 34), (45, 36), (38, 31), (41, 35),
          (39, 30), (44, 37), (43, 36), (40, 33), (37, 30),
        ],
    };
    final span = switch (range) {
      ReportRange.daily => 0,
      ReportRange.week => 6,
      ReportRange.month => 29,
    };

    final rows = [
      for (int i = 0; i < data.length; i++)
        {
          'date': ago(i).toIso8601String(),
          'checked': data[i].$1,
          'complete': data[i].$2,
        }
    ];
    final total = data.fold<int>(0, (s, e) => s + e.$1);
    final complete = data.fold<int>(0, (s, e) => s + e.$2);

    return ReportModel.fromMap({
      'start': ago(span).toIso8601String(),
      'end': today.toIso8601String(),
      'total': total,
      'complete': complete,
      'rows': rows,
    });
  }

  @override
  Future<bool> exportReport(ExportType type, ReportRange range) async => false;
}
