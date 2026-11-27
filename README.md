# Patch: Riverpod + Clean Architecture untuk proyek apdeteksi

Zip ini hanya berisi file yang BARU atau BERUBAH. File Anda yang lain
(deteksi_page, deteksi_provider, apd_detector, apd_item, live_camera_view,
app_colors, splash_page, cekapd_main) tidak disentuh dan tidak ada di zip ini.

## Langkah pasang
1. Hapus `lib/home_page.dart` (diganti `lib/presentation/pages/home_page.dart`).
2. Salin isi zip ke proyek (folder `lib/` dan `test/`), timpa file yang sama:
   - `lib/main.dart`           ProviderScope di akar aplikasi
   - `lib/main_shell.dart`     menyambungkan 5 tab; ProviderScope bawaan di sekitar DeteksiPage dihapus
   - `lib/deteksi/hasil_deteksi_page.dart`   menyimpan hasil deteksi ke riwayat
3. Hapus `test/widget_test.dart` bawaan (masih memanggil `MyApp`, akan error).
4. Tidak perlu menambah package. `flutter_riverpod ^3.3.2` sudah ada di pubspec.
5. `flutter run` ulang (bukan hot reload).

## Struktur
```
lib/
├── main.dart, main_shell.dart, app_colors.dart, splash_page.dart, cekapd_main.dart   (sudah ada)
├── deteksi/                       fitur kamera Anda (tidak diubah, kecuali hasil_deteksi_page.dart)
├── core/                          AppTone (warna tambahan), AppException, format tanggal
├── domain/                        entities, ApdRepository (interface), use case
├── data/                          InspectionModel, ApdDataSource (+ Mock), ApdRepositoryImpl
└── presentation/
    ├── providers/providers.dart   semua provider Riverpod
    ├── widgets/                   Loading / Error / Empty / AsyncValueView
    └── pages/                     Beranda, Riwayat, Statistik, Laporan
```

## Alur
Kamera -> `deteksiProvider` (milik Anda) -> `HasilDeteksiPage` -> `inspectionRecorderProvider.save()`
-> repository menyimpan -> provider Beranda/Riwayat/Statistik/Laporan di-invalidate -> data terbaru tampil.

## Catatan
- Data masih di memori (hilang saat aplikasi ditutup) dan diawali data contoh
  365 hari agar Statistik dan Laporan terisi. Mulai kosong: `MockApdDataSource(seedSampleData: false)`
  di `providers.dart`.
- Nama APD di data contoh disamakan dengan detektor: Apron, Sepatu, Kacamata, Sarung tangan, Helm las.
- `ProviderScope(retry: ...)` di main.dart mematikan auto-retry Riverpod 3 agar tampilan Error langsung muncul.
- Uji tampilan Error: `MockApdDataSource(simulateError: true)`.
- Jalankan tes: `flutter test test/apd_repository_test.dart`.
