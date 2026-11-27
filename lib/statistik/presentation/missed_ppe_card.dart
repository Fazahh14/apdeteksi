import 'package:flutter/material.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/statistik/domain/statistics_summary.dart';

const _danger = Color(0xFFB91C1C);

class MissedPpeCard extends StatelessWidget {
  final StatisticsSummary data;
  final String periodText;
  const MissedPpeCard({
    super.key,
    required this.data,
    required this.periodText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'APD yang sering terlewat',
            style: TextStyle(
              color: AppPalette.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Jumlah temuan pelanggaran $periodText',
            style: const TextStyle(color: AppPalette.subtitle, fontSize: 12),
          ),
          const SizedBox(height: 14),
          for (final m in data.missed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      m.name,
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: m.count / data.maxMissed,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFEFEBE0),
                        valueColor: const AlwaysStoppedAnimation(_danger),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${m.count}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
