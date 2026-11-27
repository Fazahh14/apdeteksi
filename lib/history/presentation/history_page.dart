import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/core/utils/date_formatter.dart';
import 'package:apdeteksi/core/widgets/async_value_view.dart';
import 'package:apdeteksi/history/domain/detection_record.dart';
import 'package:apdeteksi/history/presentation/history_providers.dart';
import 'package:apdeteksi/history/presentation/filter_chip_item.dart';
import 'package:apdeteksi/history/presentation/record_card.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static const _filterLabels = {
    HistoryFilter.all: 'Semua',
    HistoryFilter.complete: 'Lengkap',
    HistoryFilter.incomplete: 'Tidak Lengkap',
  };

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(historyDateProvider) ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) ref.read(historyDateProvider.notifier).set(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(filteredHistoryProvider);
    final filter = ref.watch(historyFilterProvider);
    final date = ref.watch(historyDateProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Deteksi',
                        style: TextStyle(
                          color: AppPalette.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Semua pemeriksaan terbaru',
                        style: TextStyle(
                            color: AppPalette.subtitle, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _pickDate(context, ref),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.calendar_today_outlined,
                        size: 20, color: AppPalette.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final f in HistoryFilter.values) ...[
                  FilterChipItem(
                    label: _filterLabels[f]!,
                    selected: filter == f,
                    onTap: () =>
                        ref.read(historyFilterProvider.notifier).set(f),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            if (date != null) ...[
              const SizedBox(height: 10),
              Chip(
                label: Text(DateFormatter.rangeText(date, date)),
                onDeleted: () =>
                    ref.read(historyDateProvider.notifier).set(null),
              ),
            ],
            const SizedBox(height: 16),
            AsyncValueView<List<DetectionRecord>>(
              value: records,
              onRetry: () => ref.invalidate(historyRecordsProvider),
              builder: (items) => _RecordList(items: items),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  final List<DetectionRecord> items;
  const _RecordList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('Tidak ada data')),
      );
    }

    final groups = <DateTime, List<DetectionRecord>>{};
    for (final r in items) {
      final d = r.detectedAt;
      groups.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(r);
    }

    final children = <Widget>[];
    for (final entry in groups.entries) {
      children.add(Padding(
        padding: EdgeInsets.only(top: children.isEmpty ? 0 : 14, bottom: 10),
        child: Text(
          DateFormatter.groupTitle(entry.key),
          style: const TextStyle(
            color: Color(0xFF3A3A3A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ));
      children.addAll(entry.value.map((r) => RecordCard(record: r)));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}
