enum ReportRange { daily, week, month }

enum ExportType { pdf, csv }

class ReportSummary {
  final int total;
  final int complete;

  const ReportSummary({required this.total, required this.complete});

  int get lacking => total - complete;
  int get rate => total == 0 ? 0 : (complete / total * 100).round();
}

class DailyReportRow {
  final DateTime date;
  final int checked;
  final int complete;

  const DailyReportRow({
    required this.date,
    required this.checked,
    required this.complete,
  });

  int get score => checked == 0 ? 0 : (complete / checked * 100).round();
}

class Report {
  final DateTime start;
  final DateTime end;
  final ReportSummary summary;
  final List<DailyReportRow> rows;

  const Report({
    required this.start,
    required this.end,
    required this.summary,
    required this.rows,
  });
}
