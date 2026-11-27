import 'package:flutter/material.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';
import 'package:apdeteksi/core/utils/date_formatter.dart';
import 'package:apdeteksi/history/domain/detection_record.dart';

class RecordCard extends StatelessWidget {
  final DetectionRecord record;
  const RecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final ok = record.isComplete;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: ok ? AppPalette.ok : AppPalette.bad,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ok ? 'Lengkap' : 'Tidak Lengkap',
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.place} • ${record.detail}',
                  style: const TextStyle(
                      color: AppPalette.subtitle, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            DateFormatter.time(record.detectedAt),
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
