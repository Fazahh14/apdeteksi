import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/laporan/data/report_data_source.dart';
import 'package:apdeteksi/laporan/data/report_repository_impl.dart';
import 'package:apdeteksi/laporan/domain/report.dart';
import 'package:apdeteksi/laporan/domain/report_repository.dart';
import 'package:apdeteksi/laporan/domain/export_report.dart';
import 'package:apdeteksi/laporan/domain/get_report.dart';

// ---- Dependency injection ----
final reportDataSourceProvider =
    Provider<ReportDataSource>((ref) => ReportMockDataSource());

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepositoryImpl(ref.watch(reportDataSourceProvider)),
);

final getReportUseCaseProvider = Provider<GetReport>(
  (ref) => GetReport(ref.watch(reportRepositoryProvider)),
);

final exportReportUseCaseProvider = Provider<ExportReport>(
  (ref) => ExportReport(ref.watch(reportRepositoryProvider)),
);

// ---- UI state ----
class ReportRangeNotifier extends Notifier<ReportRange> {
  @override
  ReportRange build() => ReportRange.week;

  void set(ReportRange range) => state = range;
}

final reportRangeProvider =
    NotifierProvider<ReportRangeNotifier, ReportRange>(ReportRangeNotifier.new);

// ---- Data ----
final reportProvider = FutureProvider<Report>((ref) {
  final range = ref.watch(reportRangeProvider);
  return ref.watch(getReportUseCaseProvider)(range);
});
