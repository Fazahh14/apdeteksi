import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/core/widgets/async_value_view.dart';
import 'package:apdeteksi/statistik/domain/statistics_summary.dart';
import 'package:apdeteksi/statistik/presentation/statistics_providers.dart';
import 'package:apdeteksi/statistik/presentation/missed_ppe_card.dart';
import 'package:apdeteksi/statistik/presentation/range_selector.dart';
import 'package:apdeteksi/statistik/presentation/score_chart_card.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  String _periodText(StatisticsRange r) => switch (r) {
        StatisticsRange.week => '7 hari terakhir',
        StatisticsRange.month => '30 hari terakhir',
        StatisticsRange.year => '365 hari terakhir',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(statisticsRangeProvider);
    final stats = ref.watch(statisticsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik',
              style: TextStyle(
                color: AppPalette.ink,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Tren kepatuhan penggunaan APD',
              style: TextStyle(color: AppPalette.subtitle, fontSize: 12),
            ),
            const SizedBox(height: 14),
            RangeSelector(
              selected: range,
              onChanged: (r) =>
                  ref.read(statisticsRangeProvider.notifier).set(r),
            ),
            const SizedBox(height: 14),
            AsyncValueView<StatisticsSummary>(
              value: stats,
              onRetry: () => ref.invalidate(statisticsProvider),
              builder: (data) => Column(
                children: [
                  ScoreChartCard(data: data, range: range),
                  const SizedBox(height: 14),
                  MissedPpeCard(data: data, periodText: _periodText(range)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
