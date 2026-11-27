import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/history/data/history_data_source.dart';
import 'package:apdeteksi/history/data/history_repository_impl.dart';
import 'package:apdeteksi/history/domain/detection_record.dart';
import 'package:apdeteksi/history/domain/history_repository.dart';
import 'package:apdeteksi/history/domain/filter_history_records.dart';
import 'package:apdeteksi/history/domain/get_history_records.dart';

// ---- Dependency injection ----
final historyDataSourceProvider =
    Provider<HistoryDataSource>((ref) => HistoryMockDataSource());

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(ref.watch(historyDataSourceProvider)),
);

final getHistoryRecordsProvider = Provider<GetHistoryRecords>(
  (ref) => GetHistoryRecords(ref.watch(historyRepositoryProvider)),
);

final filterHistoryRecordsProvider =
    Provider<FilterHistoryRecords>((ref) => const FilterHistoryRecords());

// ---- UI state ----
class HistoryFilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() => HistoryFilter.all;

  void set(HistoryFilter filter) => state = filter;
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, HistoryFilter>(
        HistoryFilterNotifier.new);

class HistoryDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void set(DateTime? date) => state = date;
}

final historyDateProvider =
    NotifierProvider<HistoryDateNotifier, DateTime?>(HistoryDateNotifier.new);

// ---- Data ----
final historyRecordsProvider = FutureProvider<List<DetectionRecord>>(
  (ref) => ref.watch(getHistoryRecordsProvider)(),
);

final filteredHistoryProvider =
    Provider<AsyncValue<List<DetectionRecord>>>((ref) {
  final filter = ref.watch(historyFilterProvider);
  final date = ref.watch(historyDateProvider);
  final filterUseCase = ref.watch(filterHistoryRecordsProvider);
  return ref
      .watch(historyRecordsProvider)
      .whenData((r) => filterUseCase(r, filter: filter, date: date));
});
