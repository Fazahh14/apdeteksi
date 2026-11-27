import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'splash_page.dart';

/// Entry point terpisah supaya main.dart tidak diubah.
/// Jalankan dengan: flutter run -t lib/cekapd_main.dart
void main() {
  runApp(const ProviderScope(child: CekApdApp()));
}

class CekApdApp extends StatelessWidget {
  const CekApdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CekAPD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
      ),
      home: const SplashPage(),
    );
  }
}
