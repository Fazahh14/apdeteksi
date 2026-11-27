import 'package:flutter/material.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/core/utils/date_formatter.dart';
import 'package:apdeteksi/laporan/domain/report.dart';

class RecapTable extends StatelessWidget {
  final List<DailyReportRow> rows;
  final String periodLabel;
  const RecapTable({super.key, required this.rows, required this.periodLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Rekap harian',
                style: TextStyle(
                  color: AppPalette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                periodLabel,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _Row(
            cells: ['Tanggal', 'Periksa', 'Lengkap', 'Skor'],
            header: true,
          ),
          for (final r in rows)
            _Row(
              cells: [
                DateFormatter.rowDate(r.date),
                '${r.checked}',
                '${r.complete}',
                '${r.score}%',
              ],
              scoreHigh: r.score >= 85,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final List<String> cells;
  final bool header;
  final bool scoreHigh;
  const _Row({required this.cells, this.header = false, this.scoreHigh = false});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      color: header ? AppPalette.subtitle : AppPalette.ink,
      fontSize: header ? 11 : 12.5,
      fontWeight: header ? FontWeight.w600 : FontWeight.w400,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(cells[0], style: base)),
          Expanded(
              flex: 2,
              child: Text(cells[1], textAlign: TextAlign.right, style: base)),
          Expanded(
              flex: 2,
              child: Text(cells[2], textAlign: TextAlign.right, style: base)),
          Expanded(
            flex: 2,
            child: Text(
              cells[3],
              textAlign: TextAlign.right,
              style: header
                  ? base
                  : base.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scoreHigh ? AppPalette.ok : AppPalette.ink,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
