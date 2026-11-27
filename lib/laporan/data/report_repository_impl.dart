import 'package:apdeteksi/laporan/domain/report.dart';
import 'package:apdeteksi/laporan/domain/report_repository.dart';
import 'package:apdeteksi/laporan/data/report_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportDataSource _dataSource;
  const ReportRepositoryImpl(this._dataSource);

  @override
  Future<Report> getReport(ReportRange range) => _dataSource.fetchReport(range);

  @override
  Future<bool> export(ExportType type, ReportRange range) =>
      _dataSource.exportReport(type, range);
}
