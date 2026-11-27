import 'package:flutter/material.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/statistik/domain/statistics_summary.dart';

extension StatisticsRangeLabel on StatisticsRange {
  String get label => switch (this) {
    StatisticsRange.week => '7 Hari',
    StatisticsRange.month => '30 Hari',
    StatisticsRange.year => '365 Hari',
  };

  String get periodLabel => switch (this) {
    StatisticsRange.week => 'minggu ini',
    StatisticsRange.month => 'bulan ini',
    StatisticsRange.year => 'tahun ini',
  };
}

class RangeSelector extends StatelessWidget {
  final StatisticsRange selected;
  final ValueChanged<StatisticsRange> onChanged;
  const RangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          for (final r in StatisticsRange.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: selected == r ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    r.label,
                    style: TextStyle(
                      color: selected == r ? Colors.white : AppPalette.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
