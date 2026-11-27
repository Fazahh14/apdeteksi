import 'package:apdeteksi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  // Ukuran layar ponsel supaya layout tidak overflow.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ProviderScope(child: MyApp()));
}

/// Ketuk splash lalu tunggu mock data (delay 300ms) selesai.
Future<void> _masukDashboard(WidgetTester tester) async {
  await tester.tap(find.text('Sistem Deteksi Kelengkapan APD'));
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> _bukaTab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(GestureDetector, label).first);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  testWidgets('splash tampil dengan judul CekAPD', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Sistem Deteksi Kelengkapan APD'), findsOneWidget);
    expect(find.text('Pantau Keselamatan'), findsOneWidget);
    expect(find.text('Pastikan Kelengkapan'), findsOneWidget);
    // "CekAPD" dibuat dari RichText dua TextSpan.
    expect(find.textContaining('CekAPD', findRichText: true), findsOneWidget);
  });

  testWidgets('ketuk splash masuk ke dashboard dengan 5 tab', (tester) async {
    await _pumpApp(tester);
    await _masukDashboard(tester);

    expect(find.text('Sistem Deteksi Kelengkapan APD'), findsNothing);
    expect(find.text('Ringkasan Hari Ini'), findsOneWidget);
    for (final tab in ['Beranda', 'Deteksi', 'Riwayat', 'Statistik', 'Laporan']) {
      expect(find.text(tab), findsOneWidget, reason: 'tab $tab tidak ada');
    }
  });

  testWidgets('tab Riwayat menampilkan data dan filter bekerja', (tester) async {
    await _pumpApp(tester);
    await _masukDashboard(tester);
    await _bukaTab(tester, 'Riwayat');

    expect(find.text('Riwayat Deteksi'), findsOneWidget);
    expect(find.text('Gudang B • 4 dari 4 APD terdeteksi'), findsOneWidget);
    expect(find.text('Gudang A • Sarung tangan terlewat'), findsOneWidget);

    // Filter "Tidak Lengkap": hanya yang tidak lengkap yang tersisa.
    await tester.tap(find.text('Tidak Lengkap'));
    await tester.pumpAndSettle();
    expect(find.text('Gudang A • Sarung tangan terlewat'), findsOneWidget);
    expect(find.text('Gudang B • 4 dari 4 APD terdeteksi'), findsNothing);

    // Filter "Lengkap": kebalikannya.
    await tester.tap(find.text('Lengkap').first);
    await tester.pumpAndSettle();
    expect(find.text('Gudang B • 4 dari 4 APD terdeteksi'), findsOneWidget);
    expect(find.text('Gudang A • Sarung tangan terlewat'), findsNothing);
  });

  testWidgets('tab Statistik menampilkan judul dan data', (tester) async {
    await _pumpApp(tester);
    await _masukDashboard(tester);
    await _bukaTab(tester, 'Statistik');

    expect(find.text('Tren kepatuhan penggunaan APD'), findsOneWidget);
    expect(find.text('Sarung tangan'), findsOneWidget);
  });

  testWidgets('tab Laporan menampilkan tombol ekspor', (tester) async {
    await _pumpApp(tester);
    await _masukDashboard(tester);
    await _bukaTab(tester, 'Laporan');

    expect(find.text('Rekapitulasi kepatuhan K3'), findsOneWidget);
    expect(find.text('Ekspor PDF'), findsOneWidget);
    expect(find.text('Ekspor CSV'), findsOneWidget);
  });
}
