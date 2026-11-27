import 'package:apdeteksi/laporan/domain/report.dart';

abstract class ReportRepository {
  Future<Report> getReport(ReportRange range);

  /// Mengembalikan false jika ekspor belum tersedia / gagal.
  Future<bool> export(ExportType type, ReportRange range);
}
