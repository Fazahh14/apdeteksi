import 'package:apdeteksi/core/utils/date_formatter.dart';
import 'package:apdeteksi/history/data/detection_record_model.dart';
import 'package:apdeteksi/history/data/history_data_source.dart';
import 'package:apdeteksi/history/data/history_repository_impl.dart';
import 'package:apdeteksi/history/domain/detection_record.dart';
import 'package:apdeteksi/history/domain/filter_history_records.dart';
import 'package:apdeteksi/history/presentation/history_providers.dart';
import 'package:apdeteksi/laporan/data/report_data_source.dart';
import 'package:apdeteksi/laporan/data/report_repository_impl.dart';
import 'package:apdeteksi/laporan/domain/report.dart';
import 'package:apdeteksi/statistik/data/statistics_data_source.dart';
import 'package:apdeteksi/statistik/data/statistics_repository_impl.dart';
import 'package:apdeteksi/statistik/domain/statistics_summary.dart';
import 'package:apdeteksi/statistik/presentation/statistics_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Data source palsu supaya hasil test tidak bergantung pada jam sekarang.
class _FakeHistoryDataSource implements HistoryDataSource {
  final List<DetectionRecordModel> records;
  _FakeHistoryDataSource(this.records);

  @override
  Future<List<DetectionRecordModel>> fetchRecords() async => records;
}

DetectionRecordModel _rec(
  String id,
  DateTime at, {
  required bool complete,
  String place = 'Lingkungan Praktik',
  String detail = '-',
}) =>
    DetectionRecordModel(
      id: id,
      detectedAt: at,
      isComplete: complete,
      place: place,
      detail: detail,
    );

void main() {
  group('Riwayat (history)', () {
    test('repository mengembalikan data dari data source', () async {
      final repo = HistoryRepositoryImpl(HistoryMockDataSource());

      final records = await repo.getRecords();

      expect(records.length, 5);
      expect(records.first.id, '1');
    });

    test('DetectionRecordModel.fromMap membaca field dengan benar', () {
      final m = DetectionRecordModel.fromMap({
        'id': 'x1',
        'detected_at': '2026-01-05T08:30:00.000',
        'is_complete': false,
        'place': 'Gudang A',
        'detail': 'Sepatu tidak terdeteksi',
      });

      expect(m.id, 'x1');
      expect(m.detectedAt, DateTime(2026, 1, 5, 8, 30));
      expect(m.isComplete, isFalse);
      expect(m.place, 'Gudang A');
    });

    test('filter lengkap / tidak lengkap / semua', () async {
      final repo = HistoryRepositoryImpl(HistoryMockDataSource());
      final records = await repo.getRecords();
      const filter = FilterHistoryRecords();

      final all = filter(records, filter: HistoryFilter.all);
      final complete = filter(records, filter: HistoryFilter.complete);
      final incomplete = filter(records, filter: HistoryFilter.incomplete);

      expect(all.length, 5);
      expect(complete.length, 3);
      expect(incomplete.length, 2);
      expect(complete.every((r) => r.isComplete), isTrue);
      expect(incomplete.every((r) => !r.isComplete), isTrue);
    });

    test('hasil filter terurut dari yang terbaru', () async {
      final repo = HistoryRepositoryImpl(HistoryMockDataSource());
      final result = const FilterHistoryRecords()(
        await repo.getRecords(),
        filter: HistoryFilter.all,
      );

      for (var i = 1; i < result.length; i++) {
        expect(
          result[i - 1].detectedAt.isBefore(result[i].detectedAt),
          isFalse,
        );
      }
    });

    test('filter tanggal hanya mengambil hari yang dipilih', () async {
      final repo = HistoryRepositoryImpl(HistoryMockDataSource());
      final records = await repo.getRecords();

      final today = const FilterHistoryRecords()(
        records,
        filter: HistoryFilter.all,
        date: DateTime.now(),
      );
      final todayIncomplete = const FilterHistoryRecords()(
        records,
        filter: HistoryFilter.incomplete,
        date: DateTime.now(),
      );

      expect(today.length, 3);
      expect(todayIncomplete.length, 1);
      expect(todayIncomplete.first.place, 'Jalur Perakitan');
    });

    test('data kosong menghasilkan list kosong', () {
      final result = const FilterHistoryRecords()(
        const [],
        filter: HistoryFilter.complete,
      );
      expect(result, isEmpty);
    });

    test('provider: filter state mengubah hasil riwayat', () async {
      final container = ProviderContainer(
        overrides: [
          historyDataSourceProvider.overrideWithValue(
            _FakeHistoryDataSource([
              _rec('a', DateTime(2026, 1, 2, 9), complete: true),
              _rec('b', DateTime(2026, 1, 2, 10), complete: false),
              _rec('c', DateTime(2026, 1, 1, 8), complete: false),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(historyRecordsProvider.future);

      expect(container.read(filteredHistoryProvider).requireValue.length, 3);

      container
          .read(historyFilterProvider.notifier)
          .set(HistoryFilter.incomplete);
      final incomplete = container.read(filteredHistoryProvider).requireValue;
      expect(incomplete.map((r) => r.id), ['b', 'c']);

      container
          .read(historyDateProvider.notifier)
          .set(DateTime(2026, 1, 2));
      final byDate = container.read(filteredHistoryProvider).requireValue;
      expect(byDate.map((r) => r.id), ['b']);
    });
  });

  group('Statistik', () {
    late StatisticsRepositoryImpl repo;
    setUp(() => repo = StatisticsRepositoryImpl(StatisticsMockDataSource()));

    test('7 hari memiliki 7 batang dan skor 0..1', () async {
      final stats = await repo.getStatistics(StatisticsRange.week);

      expect(stats.scores.length, 7);
      expect(stats.scores.map((s) => s.label).toList(),
          DateFormatter.days);
      expect(stats.averageScore, inInclusiveRange(0, 100));
      expect(stats.scores.every((s) => s.value >= 0 && s.value <= 1), isTrue);
    });

    test('bulan = 4 minggu, tahun = 12 bulan', () async {
      final month = await repo.getStatistics(StatisticsRange.month);
      final year = await repo.getStatistics(StatisticsRange.year);

      expect(month.scores.length, 4);
      expect(year.scores.length, 12);
    });

    test('APD terlewat terurut dari yang terbanyak', () async {
      for (final range in StatisticsRange.values) {
        final stats = await repo.getStatistics(range);

        expect(stats.missed, isNotEmpty);
        for (var i = 1; i < stats.missed.length; i++) {
          expect(stats.missed[i - 1].count >= stats.missed[i].count, isTrue,
              reason: 'range $range tidak terurut');
        }
        expect(stats.maxMissed, stats.missed.first.count);
      }
    });

    test('maxMissed bernilai 1 jika tidak ada data terlewat', () {
      const s = StatisticsSummary(
        averageScore: 100,
        trendPercent: 0,
        scores: [],
        missed: [],
      );
      expect(s.maxMissed, 1);
    });

    test('provider: mengganti range mengubah data', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final week = await container.read(statisticsProvider.future);
      expect(week.scores.length, 7);

      container
          .read(statisticsRangeProvider.notifier)
          .set(StatisticsRange.year);
      final year = await container.read(statisticsProvider.future);
      expect(year.scores.length, 12);
    });
  });

  group('Laporan', () {
    late ReportRepositoryImpl repo;
    setUp(() => repo = ReportRepositoryImpl(ReportMockDataSource()));

    test('jumlah baris sesuai rentang', () async {
      expect((await repo.getReport(ReportRange.daily)).rows.length, 1);
      expect((await repo.getReport(ReportRange.week)).rows.length, 4);
      expect((await repo.getReport(ReportRange.month)).rows.length, 10);
    });

    test('ringkasan = jumlah dari semua baris', () async {
      for (final range in ReportRange.values) {
        final r = await repo.getReport(range);

        expect(r.summary.total, r.rows.fold<int>(0, (s, e) => s + e.checked));
        expect(
            r.summary.complete, r.rows.fold<int>(0, (s, e) => s + e.complete));
        expect(r.summary.lacking, r.summary.total - r.summary.complete);
        expect(r.summary.rate, inInclusiveRange(0, 100));
      }
    });

    test('perhitungan rate dan score', () {
      expect(const ReportSummary(total: 42, complete: 36).rate, 86);
      expect(const ReportSummary(total: 0, complete: 0).rate, 0);
      expect(
        DailyReportRow(date: DateTime(2026), checked: 40, complete: 34).score,
        85,
      );
      expect(
        DailyReportRow(date: DateTime(2026), checked: 0, complete: 0).score,
        0,
      );
    });

    test('rentang tanggal: start <= end dan end = hari ini', () async {
      final r = await repo.getReport(ReportRange.week);
      final now = DateTime.now();

      expect(r.start.isAfter(r.end), isFalse);
      expect(DateFormatter.isSameDay(r.end, now), isTrue);
    });

    test('ekspor belum tersedia (mengembalikan false)', () async {
      expect(await repo.export(ExportType.pdf, ReportRange.week), isFalse);
      expect(await repo.export(ExportType.csv, ReportRange.week), isFalse);
    });
  });

  group('DateFormatter', () {
    test('isSameDay & time', () {
      expect(DateFormatter.isSameDay(DateTime(2026, 3, 4, 1), DateTime(2026, 3, 4, 23)), isTrue);
      expect(DateFormatter.isSameDay(DateTime(2026, 3, 4), DateTime(2026, 3, 5)), isFalse);
      expect(DateFormatter.time(DateTime(2026, 1, 1, 7, 5)), '07:05');
    });

    test('groupTitle: Hari ini / Kemarin', () {
      final now = DateTime(2026, 5, 10, 12);
      expect(DateFormatter.groupTitle(DateTime(2026, 5, 10), now),
          'Hari ini • 10 Mei');
      expect(DateFormatter.groupTitle(DateTime(2026, 5, 9), now),
          'Kemarin • 9 Mei');
    });

    test('rangeText', () {
      expect(DateFormatter.rangeText(DateTime(2026, 5, 10), DateTime(2026, 5, 10)),
          '10 Mei 2026');
      expect(DateFormatter.rangeText(DateTime(2026, 5, 4), DateTime(2026, 5, 10)),
          '4 – 10 Mei 2026');
      expect(DateFormatter.rangeText(DateTime(2026, 4, 28), DateTime(2026, 5, 4)),
          '28 April – 4 Mei 2026');
    });
  });
}
