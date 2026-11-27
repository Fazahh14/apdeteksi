import 'package:apdeteksi/laporan/domain/report.dart';
import 'package:apdeteksi/laporan/domain/report_repository.dart';

class ExportReport {
  final ReportRepository _repository;
  const ExportReport(this._repository);

  Future<bool> call(ExportType type, ReportRange range) =>
      _repository.export(type, range);
}
