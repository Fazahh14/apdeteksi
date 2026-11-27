import 'package:flutter/material.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/core/theme/app_palette.dart';

class _Inspection {
  final bool complete;
  final String detail;
  final String time;
  const _Inspection(this.complete, this.detail, this.time);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  // Data contoh, ganti dengan data asli dari hasil deteksi.
  static const _total = 42;
  static const _complete = 36;
  static const _items = [
    _Inspection(true, '4 dari 4 APD terdeteksi', '08:42'),
    _Inspection(false, 'Sepatu tidak terdeteksi', '08:32'),
    _Inspection(true, '4 dari 4 APD terdeteksi', '08:30'),
    _Inspection(false, 'Sarung tangan tidak terdeteksi', '08:28'),
  ];

  String _today() {
    final n = DateTime.now();
    return '${_days[n.weekday - 1]}, ${n.day} ${_months[n.month - 1]} ${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    final incomplete = _total - _complete;
    final percent = _complete / _total;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                _today(),
                style: const TextStyle(color: AppColors.navy, fontSize: 14),
              ),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                'Ringkasan Hari Ini',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SummaryCard(percent: percent, total: _total, complete: _complete),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'APD lengkap',
                    value: _complete,
                    ok: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Tidak lengkap',
                    value: incomplete,
                    ok: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat semua',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: AppColors.navy, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _items.length; i++) ...[
                    _InspectionTile(item: _items[i]),
                    if (i != _items.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.divider,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double percent;
  final int total;
  final int complete;
  const _SummaryCard({
    required this.percent,
    required this.total,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Kelengkapan APD',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.track,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$total pemeriksaan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '${(percent * 100).round()} %',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 12,
                    backgroundColor: AppColors.track,
                    valueColor: const AlwaysStoppedAnimation(AppColors.yellow),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.white),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$complete dari $total orang masuk dengan APD lengkap',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool ok;
  final double size;
  const _StatusIcon({required this.ok, this.size = 26});

  // Sama dengan ikon di halaman Riwayat (RecordCard).
  @override
  Widget build(BuildContext context) {
    return Icon(
      ok ? Icons.check_circle_outline : Icons.cancel_outlined,
      color: ok ? AppPalette.ok : AppPalette.bad,
      size: size,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final bool ok;
  const _StatCard({required this.label, required this.value, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatusIcon(ok: ok, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FittedBox: teks mengecil otomatis, tidak pernah terpotong.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppPalette.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
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

class _InspectionTile extends StatelessWidget {
  final _Inspection item;
  const _InspectionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          _StatusIcon(ok: item.complete),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.complete ? 'Lengkap' : 'Tidak lengkap',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            item.time,
            style: const TextStyle(color: AppColors.navy, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
