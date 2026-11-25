import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      // Ketuk di mana saja untuk masuk ke dashboard.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToDashboard,
        child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(160, 140),
                    painter: _ScanCornerPainter(),
                  ),
                  Container(
                    width: 88,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      size: 52,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(text: 'Cek', style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'APD', style: TextStyle(color: AppColors.yellow)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sistem Deteksi Kelengkapan APD',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 18),
            Container(width: 72, height: 2, color: AppColors.yellow),
            const SizedBox(height: 28),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pantau Keselamatan',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                SizedBox(height: 4),
                Text('Pastikan Kelengkapan',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Empat sudut kuning seperti bingkai scanner.
class _ScanCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const arm = 46.0; // panjang garis lurus
    const r = 14.0; // radius sudut
    final w = size.width;
    final h = size.height;

    final path = Path()
      // kiri atas
      ..moveTo(0, arm)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(arm, 0)
      // kanan atas
      ..moveTo(w - arm, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, arm)
      // kanan bawah
      ..moveTo(w, h - arm)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(w - arm, h)
      // kiri bawah
      ..moveTo(arm, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, h - arm);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
