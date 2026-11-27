import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../shell/nav_provider.dart';
import 'apd_item.dart';

const _kGreenDark = Color(0xFF2E8B3D);
const _kGreenIcon = Color(0xFF3FAE5A);
const _kGreenPill = Color(0xFFBFE8C7);
const _kRed = Color(0xFFE5484D);
const _kRedDark = Color(0xFFB3202A);
const _kRedPill = Color(0xFFF8B4B4);
const _kOrange = Color(0xFFF5A524);
const _kCardBorder = Color(0xFFD9D4C2);

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

const _bulan = [
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

String _tanggal(DateTime d) =>
    '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

String _jam(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
}

String _gabung(List<String> names) {
  if (names.length <= 1) return names.join();
  return '${names.sublist(0, names.length - 1).join(', ')} dan ${names.last}';
}

/// Halaman detail hasil deteksi.
///
/// Menutup dengan `pop(true)` saat tombol "Periksa lagi" ditekan, supaya
/// halaman sebelumnya bisa mengosongkan hasil.
class HasilDeteksiPage extends ConsumerWidget {
  const HasilDeteksiPage({
    super.key,
    required this.items,
    required this.waktu,
    this.snapshot,
    this.onKeRiwayat,
  });

  final List<ApdItem> items;
  final DateTime waktu;

  /// Foto hasil tangkapan kamera (opsional). Jika null, kartu tampil hitam.
  final Uint8List? snapshot;

  final VoidCallback? onKeRiwayat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detected = items.where((e) => e.isDetected).length;
    final missing = items
        .where((e) => !e.isDetected)
        .map((e) => e.name)
        .toList();
    final complete = items.isNotEmpty && missing.isEmpty;

    final String title;
    final String message;
    if (complete) {
      title = 'APD lengkap';
      message = 'Semua ${items.length} APD wajib terdeteksi';
    } else if (detected == 0) {
      title = 'APD tidak lengkap';
      message = 'Belum ada APD yang terdeteksi';
    } else {
      title = 'APD tidak lengkap';
      message = '${_gabung(missing)} tidak terdeteksi';
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              _Header(waktu: waktu),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      _FadeIn(
                        child: _PreviewCard(waktu: waktu, snapshot: snapshot),
                      ),
                      const SizedBox(height: 14),
                      _FadeIn(
                        delay: const Duration(milliseconds: 90),
                        child: _ResultAlert(
                          complete: complete,
                          title: title,
                          message: message,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FadeIn(
                        delay: const Duration(milliseconds: 180),
                        child: _ResultList(items: items),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(navIndexProvider.notifier)
                                .select(2); // tab Riwayat
                            Navigator.of(context).pop();
                            onKeRiwayat?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.5,
                            ),
                            side: BorderSide(
                              color: AppColors.navy.withValues(alpha: 0.45),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Ke Riwayat',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          icon: const Icon(
                            Icons.center_focus_strong_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Periksa lagi',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.waktu});
  final DateTime waktu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            color: AppColors.navy,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasil Deteksi',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _tanggal(waktu),
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.6),
                    fontSize: 11.5,
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.waktu, this.snapshot});

  final DateTime waktu;
  final Uint8List? snapshot;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (snapshot != null)
              Image.memory(snapshot!, fit: BoxFit.cover)
            else
              const ColoredBox(color: Colors.black),
            // gradien agar teks selalu terbaca di atas foto
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x80000000),
                    Color(0x00000000),
                    Color(0x99000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 14,
              child: Text(
                _jam(waktu),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Positioned(
              left: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendDot(color: _kGreenIcon, text: 'APD lengkap'),
                  SizedBox(height: 5),
                  _LegendDot(color: _kOrange, text: 'APD tidak lengkap'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 10.5)),
      ],
    );
  }
}

class _ResultAlert extends StatelessWidget {
  const _ResultAlert({
    required this.complete,
    required this.title,
    required this.message,
  });

  final bool complete;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final accent = complete ? _kGreenDark : _kRedDark;
    final iconColor = complete ? _kGreenIcon : _kRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: complete ? const Color(0xFFDDF3E1) : const Color(0xFFFAC9C9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: complete ? const Color(0xFFB5E0BD) : const Color(0xFFF4A8A8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Icon(
              complete ? Icons.check : Icons.priority_high,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.navy, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.items});
  final List<ApdItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ResultRow(item: items[i]),
            if (i != items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 14,
                endIndent: 14,
                color: AppColors.navy.withValues(alpha: 0.07),
              ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.item});
  final ApdItem item;

  @override
  Widget build(BuildContext context) {
    final ok = item.isDetected;
    final color = ok ? _kGreenIcon : _kRed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(ok ? Icons.check : Icons.close, color: color, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ok ? _kGreenPill : _kRedPill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ok ? item.confidenceCompact : 'Tidak terdeteksi',
              style: TextStyle(
                color: ok ? _kGreenDark : _kRedDark,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muncul pelan dari bawah, dengan jeda opsional.
class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
