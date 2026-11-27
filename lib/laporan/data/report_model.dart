import 'package:apdeteksi/laporan/domain/report.dart';

class ReportModel extends Report {
  const ReportModel({
    required super.start,
    required super.end,
    required super.summary,
    required super.rows,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
      summary: ReportSummary(
        total: map['total'] as int,
        complete: map['complete'] as int,
      ),
      rows: (map['rows'] as List)
          .map((e) => DailyReportRow(
                date: DateTime.parse(e['date'] as String),
                checked: e['checked'] as int,
                complete: e['complete'] as int,
              ))
          .toList(),
    );
  }
}
