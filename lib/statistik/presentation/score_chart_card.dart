import 'package:flutter/material.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/statistik/domain/statistics_summary.dart';
import 'range_selector.dart';

class ScoreChartCard extends StatelessWidget {
  final StatisticsSummary data;
  final StatisticsRange range;
  const ScoreChartCard({super.key, required this.data, required this.range});

  Color _barColor(int i, DailyScore s) {
    if (i == data.scores.length - 1) return AppColors.navy;
    if (s.value < 0.5) return AppPalette.amber;
    return AppPalette.ok;
  }

  @override
  Widget build(BuildContext context) {
    final trend = data.trendPercent;
    final positive = trend >= 0;
    final trendColor = positive ? AppPalette.ok : AppPalette.bad;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skor rata-rata',
                style: TextStyle(color: AppPalette.subtitle, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: positive
                      ? const Color(0xFFE3F3E5)
                      : const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${positive ? '+' : ''}$trend% ${range.periodLabel}',
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${data.averageScore}%',
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 34,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < data.scores.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 100,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 100 * data.scores[i].value,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _barColor(i, data.scores[i]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.scores[i].label,
                          style: const TextStyle(
                            color: AppPalette.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
