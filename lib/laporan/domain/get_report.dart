import 'package:apdeteksi/laporan/domain/report.dart';
import 'package:apdeteksi/laporan/domain/report_repository.dart';

class GetReport {
  final ReportRepository _repository;
  const GetReport(this._repository);

  Future<Report> call(ReportRange range) => _repository.getReport(range);
}
