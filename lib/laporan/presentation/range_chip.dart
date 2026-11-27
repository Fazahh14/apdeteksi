import 'package:flutter/material.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/laporan/domain/report.dart';

extension ReportRangeLabel on ReportRange {
  String get label => switch (this) {
    ReportRange.daily => 'Harian',
    ReportRange.week => '7 Hari',
    ReportRange.month => '30 Hari',
  };

  String get recapLabel => switch (this) {
    ReportRange.daily => 'Hari ini',
    ReportRange.week => '7 hari terakhir',
    ReportRange.month => '30 hari terakhir',
  };
}

class RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const RangeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.navy : AppPalette.chipBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
