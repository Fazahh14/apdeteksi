import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/core/widgets/async_value_view.dart';
import 'package:apdeteksi/laporan/domain/report.dart';
import 'package:apdeteksi/laporan/presentation/report_providers.dart';
import 'package:apdeteksi/laporan/presentation/export_button.dart';
import 'package:apdeteksi/laporan/presentation/range_chip.dart';
import 'package:apdeteksi/laporan/presentation/recap_table.dart';
import 'package:apdeteksi/laporan/presentation/summary_card.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  Future<void> _export(
      BuildContext context, WidgetRef ref, ExportType type) async {
    final range = ref.read(reportRangeProvider);
    final ok = await ref.read(exportReportUseCaseProvider)(type, range);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ekspor ${type.name.toUpperCase()} belum tersedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reportRangeProvider);
    final report = ref.watch(reportProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
                        'Laporan',
                        style: TextStyle(
                          color: AppPalette.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rekapitulasi kepatuhan K3',
                        style: TextStyle(
                            color: AppPalette.subtitle, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.edit_calendar_outlined,
                      size: 22, color: AppPalette.ink),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final r in ReportRange.values) ...[
                  RangeChip(
                    label: r.label,
                    selected: range == r,
                    onTap: () => ref.read(reportRangeProvider.notifier).set(r),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 14),
            AsyncValueView<Report>(
              value: report,
              onRetry: () => ref.invalidate(reportProvider),
              builder: (data) => Column(
                children: [
                  SummaryCard(report: data),
                  const SizedBox(height: 14),
                  RecapTable(rows: data.rows, periodLabel: range.recapLabel),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ExportButton(
                    label: 'Ekspor PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    filled: false,
                    onTap: () => _export(context, ref, ExportType.pdf),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExportButton(
                    label: 'Ekspor CSV',
                    icon: Icons.download,
                    filled: true,
                    onTap: () => _export(context, ref, ExportType.csv),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
