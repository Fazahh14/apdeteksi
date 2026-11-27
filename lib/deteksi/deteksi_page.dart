import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import 'apd_item.dart';
import 'deteksi_provider.dart';
import 'hasil_deteksi_page.dart';
import 'live_camera_view.dart';

const _kGreenDark = Color(0xFF2E8B3D);
const _kGreenIcon = Color(0xFF3FAE5A);
const _kGreenSoft = Color(0xFFE3F5E6);
const _kRed = Color(0xFFE5484D);
const _kRedSoft = Color(0xFFFDE8E8);
const _kCardBorder = Color(0xFFD0D0D0);
const _kSubtle = Color(0xFF6B7280);
const _kPillAuto = Color(0xFF1F6B2E);
const _kPillOff = Color(0xFF7A2A2A);

class DeteksiPage extends ConsumerWidget {
  const DeteksiPage({
    super.key,
    this.onLihatHasil,
    this.onKeRiwayat,
    this.isActive = true,
  });

  /// Jika diisi, menggantikan perilaku bawaan (membuka halaman hasil).
  final VoidCallback? onLihatHasil;

  /// Dipanggil saat tombol "Ke Riwayat" di halaman hasil ditekan
  /// (misalnya untuk pindah ke tab Riwayat).
  final VoidCallback? onKeRiwayat;
  final bool isActive;

  Future<void> _bukaHasil(
    BuildContext context,
    WidgetRef ref,
    DeteksiState state,
  ) async {
    final ulang = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HasilDeteksiPage(
          items: state.items,
          waktu: DateTime.now(),
          onKeRiwayat: onKeRiwayat,
        ),
      ),
    );
    if (ulang == true && context.mounted) {
      ref.read(deteksiProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deteksiProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: _CameraView(
                state: state,
                active: isActive,
                onCameraStatus: (v) =>
                    ref.read(deteksiProvider.notifier).setCameraActive(v),
                onFrame: (image, rotation, mirrored) => ref
                    .read(deteksiProvider.notifier)
                    .processFrame(
                      image,
                      rotation: rotation,
                      mirrored: mirrored,
                    ),
              ),
            ),
            _StatusPanel(
              state: state,
              onLihatHasil:
                  onLihatHasil ?? () => _bukaHasil(context, ref, state),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Kamera

class _CameraView extends StatelessWidget {
  const _CameraView({
    required this.state,
    required this.active,
    this.onCameraStatus,
    this.onFrame,
  });

  final DeteksiState state;
  final bool active;
  final ValueChanged<bool>? onCameraStatus;
  final CameraFrameCallback? onFrame;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      fit: StackFit.expand,
      children: [
        LiveCameraView(
          active: active,
          onStatusChanged: onCameraStatus,
          onFrame: onFrame,
          placeholder: const ColoredBox(color: Colors.black),
        ),
        // Bayangan lembut di atas supaya pill terbaca jelas
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topInset + 90,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x99000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
        ),
        // Boks deteksi
        IgnorePointer(child: CustomPaint(painter: _BoxPainter(state.items))),
        // Bingkai sudut + garis pindai
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.fromLTRB(36, topInset + 56, 36, 56),
              child: _ScanFrame(
                complete: state.isComplete,
                scanning: state.cameraActive,
              ),
            ),
          ),
        ),
        // Petunjuk saat belum ada yang terdeteksi
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: state.cameraActive && state.detectedCount == 0 ? 1 : 0,
              child: const Center(child: _HintChip()),
            ),
          ),
        ),
        // Status kamera
        Positioned(
          top: topInset + 12,
          right: 16,
          child: _StatusPill(active: state.cameraActive),
        ),
      ],
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.center_focus_strong_rounded,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(width: 6),
          Text(
            'Posisikan seluruh badan di dalam bingkai',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: (active ? _kPillAuto : _kPillOff).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(
            color: active ? const Color(0xFF6EE787) : const Color(0xFFFF8A8A),
            pulsing: active,
          ),
          const SizedBox(width: 7),
          Text(
            active ? 'Kamera aktif' : 'Kamera nonaktif',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color, required this.pulsing});
  final Color color;
  final bool pulsing;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = widget.pulsing ? _c.value : 0.0;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6 * (1 - t)),
                blurRadius: 2,
                spreadRadius: 5 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Bingkai sudut dengan garis pindai yang bergerak.
class _ScanFrame extends StatefulWidget {
  const _ScanFrame({required this.complete, required this.scanning});
  final bool complete;
  final bool scanning;

  @override
  State<_ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<_ScanFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.complete ? _kGreenIcon : Colors.white;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: target),
      duration: const Duration(milliseconds: 400),
      builder: (_, color, __) => CustomPaint(
        size: Size.infinite,
        painter: _FramePainter(
          anim: _c,
          color: color ?? Colors.white,
          scanning: widget.scanning && !widget.complete,
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter({
    required this.anim,
    required this.color,
    required this.scanning,
  }) : super(repaint: anim);

  final Animation<double> anim;
  final Color color;
  final bool scanning;

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 56.0;
    const r = 22.0;
    final w = size.width;
    final h = size.height;

    // Garis pindai
    if (scanning) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, w, h));
      final y = anim.value * h;
      final glow = Rect.fromLTWH(8, y - 46, w - 16, 46);
      canvas.drawRect(
        glow,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.28)],
          ).createShader(glow),
      );
      canvas.drawLine(
        Offset(8, y),
        Offset(w - 8, y),
        Paint()
          ..color = color.withValues(alpha: 0.95)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    // Sudut-sudut bingkai
    final p = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, arm)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(arm, 0),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - arm, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
        ..lineTo(w, arm),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h - arm)
        ..lineTo(0, h - r)
        ..arcToPoint(
          Offset(r, h),
          radius: const Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(arm, h),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - arm, h)
        ..lineTo(w - r, h)
        ..arcToPoint(
          Offset(w, h - r),
          radius: const Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(w, h - arm),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) =>
      old.color != color || old.scanning != scanning;
}

class _BoxPainter extends CustomPainter {
  _BoxPainter(this.items);
  final List<ApdItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    for (final item in items) {
      final box = item.box;
      if (box == null) continue;

      final color = item.isDetected ? _kGreenIcon : _kRed;
      final rect = Rect.fromLTWH(
        box.left * size.width,
        box.top * size.height,
        box.width * size.width,
        box.height * size.height,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

      // isian transparan + garis tepi
      canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: 0.12));
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final label = item.isDetected
          ? '${item.boxLabel} ${item.confidenceCompact}'
          : '${item.boxLabel}: Tidak sesuai';

      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);

      const padX = 7.0;
      const padY = 3.0;
      final lw = painter.width + padX * 2;
      final lh = painter.height + padY * 2;
      var top = rect.top - lh - 3;
      if (top < 0) top = rect.top + 3;
      var left = rect.left;
      if (left + lw > size.width) left = size.width - lw;
      if (left < 0) left = 0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, lw, lh),
          const Radius.circular(10),
        ),
        Paint()..color = item.isDetected ? _kGreenDark : _kRed,
      );
      painter.paint(canvas, Offset(left + padX, top + padY));
    }
  }

  @override
  bool shouldRepaint(covariant _BoxPainter old) => old.items != items;
}

// ---------------------------------------------------------------- Panel

IconData _apdIcon(String id) {
  switch (id) {
    case 'apron':
      return Icons.checkroom_rounded;
    case 'sepatu':
      return Icons.hiking_rounded;
    case 'kacamata':
      return Icons.visibility_rounded;
    case 'sarung_tangan':
      return Icons.back_hand_rounded;
    case 'helm_las':
      return Icons.engineering_rounded;
    default:
      return Icons.shield_rounded;
  }
}

/// Panel status yang bisa digeser: 1.0 = terbuka penuh, 0.0 = diringkas.
class _StatusPanel extends StatefulWidget {
  const _StatusPanel({required this.state, this.onLihatHasil});

  final DeteksiState state;
  final VoidCallback? onLihatHasil;

  @override
  State<_StatusPanel> createState() => _StatusPanelState();
}

class _StatusPanelState extends State<_StatusPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    value: 1,
    duration: const Duration(milliseconds: 280),
  );
  final _contentKey = GlobalKey();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _range => _contentKey.currentContext?.size?.height ?? 220;

  void _onDragUpdate(DragUpdateDetails d) {
    _c.value = (_c.value - d.delta.dy / _range).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    final target = v.abs() > 500
        ? (v < 0 ? 1.0 : 0.0)
        : (_c.value > 0.5 ? 1.0 : 0.0);
    _c.animateTo(target, curve: Curves.easeOutCubic);
  }

  void _toggle() {
    _c.animateTo(_c.value > 0.5 ? 0.0 : 1.0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final rows = <Widget>[];
    for (var i = 0; i < state.items.length; i += 2) {
      final left = state.items[i];
      final right = i + 1 < state.items.length ? state.items[i + 1] : null;

      rows.add(
        right == null
            ? _ApdCard(item: left)
            : Row(
                children: [
                  Expanded(child: _ApdCard(item: left)),
                  const SizedBox(width: 10),
                  Expanded(child: _ApdCard(item: right)),
                ],
              ),
      );
      if (i + 2 < state.items.length) rows.add(const SizedBox(height: 10));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // pegangan: ketuk untuk buka/tutup, atau geser
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 60,
                    ),
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _AlertHeader(
                  isComplete: state.isComplete,
                  count: state.detectedCount,
                  total: state.items.length,
                  title: state.alertTitle,
                  message: state.alertMessage,
                ),
                // ringkasan saat panel diciutkan
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1 - t,
                    child: Opacity(
                      opacity: 1 - t,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: _MiniStatusRow(items: state.items),
                      ),
                    ),
                  ),
                ),
                // isi lengkap saat panel dibuka
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: t,
                    child: Opacity(
                      opacity: t,
                      child: Column(
                        key: _contentKey,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          ...rows,
                          const SizedBox(height: 16),
                          _ResultButton(onPressed: widget.onLihatHasil),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Ikon APD. Apron, sepatu, kacamata, dan helm las digambar manual karena
/// Material Icons tidak punya ikon yang tepat untuk itu.
class _ApdGlyph extends StatelessWidget {
  const _ApdGlyph({required this.id, required this.color, this.size = 22});

  final String id;
  final Color color;
  final double size;

  static const _custom = {'apron', 'sepatu', 'kacamata', 'helm_las'};

  @override
  Widget build(BuildContext context) {
    if (!_custom.contains(id)) {
      return Icon(_apdIcon(id), size: size, color: color);
    }
    return CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(id, color),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.id, this.color);

  final String id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // semua koordinat di bawah memakai kanvas 24 x 24
    canvas.scale(size.width / 24);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color.withValues(alpha: 0.18);

    void closed(Path p) {
      canvas.drawPath(p, fill);
      canvas.drawPath(p, stroke);
    }

    void open(Path p) => canvas.drawPath(p, stroke);

    switch (id) {
      case 'apron':
        // tali leher
        open(
          Path()
            ..moveTo(9, 8)
            ..cubicTo(9, 2.5, 15, 2.5, 15, 8),
        );
        // badan apron
        closed(
          Path()
            ..moveTo(9, 8)
            ..lineTo(15, 8)
            ..lineTo(15, 11)
            ..lineTo(18, 21)
            ..lineTo(6, 21)
            ..lineTo(9, 11)
            ..close(),
        );
        // tali pinggang
        open(
          Path()
            ..moveTo(9, 11)
            ..lineTo(5.5, 10.5)
            ..moveTo(15, 11)
            ..lineTo(18.5, 10.5),
        );
        // kantong
        open(
          Path()
            ..moveTo(10, 15)
            ..lineTo(14, 15)
            ..lineTo(14, 18)
            ..lineTo(10, 18)
            ..close(),
        );
        break;

      case 'sepatu':
        // sepatu bot safety tampak samping
        closed(
          Path()
            ..moveTo(6.5, 3)
            ..lineTo(13, 3)
            ..lineTo(13, 9.5)
            ..cubicTo(14, 11.5, 17.5, 12, 19.5, 14)
            ..cubicTo(20.7, 15.2, 21, 16, 21, 17)
            ..lineTo(21, 20)
            ..lineTo(6.5, 20)
            ..close(),
        );
        // sol
        open(
          Path()
            ..moveTo(6.5, 16.5)
            ..lineTo(21, 16.5),
        );
        // tali
        open(
          Path()
            ..moveTo(13, 6)
            ..lineTo(10, 6)
            ..moveTo(13, 8.5)
            ..lineTo(10, 8.5),
        );
        break;

      case 'kacamata':
        closed(
          Path()..addOval(
            Rect.fromCircle(center: const Offset(6.8, 13), radius: 3.8),
          ),
        );
        closed(
          Path()..addOval(
            Rect.fromCircle(center: const Offset(17.2, 13), radius: 3.8),
          ),
        );
        // jembatan hidung
        open(
          Path()
            ..moveTo(10.4, 12.2)
            ..quadraticBezierTo(12, 10.6, 13.6, 12.2),
        );
        // gagang
        open(
          Path()
            ..moveTo(3.1, 12.2)
            ..lineTo(2, 9.5)
            ..moveTo(20.9, 12.2)
            ..lineTo(22, 9.5),
        );
        break;

      case 'helm_las':
        // topeng/helm las
        closed(
          Path()
            ..moveTo(4, 15)
            ..cubicTo(4, 7, 7.5, 3.5, 12, 3.5)
            ..cubicTo(16.5, 3.5, 20, 7, 20, 15)
            ..lineTo(20, 17.5)
            ..lineTo(17, 20.5)
            ..lineTo(7, 20.5)
            ..lineTo(4, 17.5)
            ..close(),
        );
        // kaca pelindung
        final visor = RRect.fromRectAndRadius(
          const Rect.fromLTRB(7, 10.5, 17, 15.5),
          const Radius.circular(1.8),
        );
        canvas.drawRRect(visor, Paint()..color = color.withValues(alpha: 0.4));
        canvas.drawRRect(visor, stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.id != id || old.color != color;
}

class _MiniStatusRow extends StatelessWidget {
  const _MiniStatusRow({required this.items});
  final List<ApdItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final item in items)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isDetected ? _kGreenSoft : _kRedSoft,
              border: Border.all(
                color: item.isDetected ? _kGreenIcon : _kRed,
                width: 1.5,
              ),
            ),
            child: _ApdGlyph(
              id: item.id,
              size: 22,
              color: item.isDetected ? _kGreenDark : _kRed,
            ),
          ),
      ],
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.navy,
            disabledBackgroundColor: AppColors.yellow,
            disabledForegroundColor: AppColors.navy,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Lihat hasil deteksi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 10),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navy,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: AppColors.yellow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertHeader extends StatelessWidget {
  const _AlertHeader({
    required this.isComplete,
    required this.count,
    required this.total,
    required this.title,
    required this.message,
  });

  final bool isComplete;
  final int count;
  final int total;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final accent = isComplete ? _kGreenIcon : _kRed;
    final progress = total == 0 ? 0.0 : count / total;

    return Row(
      children: [
        // cincin progres
        TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: v,
                    strokeWidth: 4.5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(
                      isComplete ? _kGreenIcon : const Color(0xFFF5A524),
                    ),
                  ),
                ),
                Text(
                  '$count/$total',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [...previous, if (current != null) current],
                ),
                child: Row(
                  key: ValueKey(title),
                  children: [
                    Icon(
                      isComplete
                          ? Icons.verified_rounded
                          : Icons.error_outline_rounded,
                      color: accent,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(color: _kSubtle, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApdCard extends StatelessWidget {
  const _ApdCard({required this.item});

  final ApdItem item;

  @override
  Widget build(BuildContext context) {
    final ok = item.isDetected;
    final color = ok ? _kGreenIcon : _kRed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFF1FAF3) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ok ? _kGreenIcon.withValues(alpha: 0.55) : _kCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: (ok ? _kGreenIcon : Colors.black).withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Container(
              key: ValueKey(ok),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ok ? _kGreenSoft : _kRedSoft,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Icon(
                ok ? Icons.check : Icons.close,
                color: color,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  ok ? item.confidenceCompact : 'Belum terdeteksi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ok ? _kGreenDark : _kRed,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _ApdGlyph(
            id: item.id,
            size: 24,
            color: AppColors.navy.withValues(alpha: 0.16),
          ),
        ],
      ),
    );
  }
}
