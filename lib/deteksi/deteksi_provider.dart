import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'apd_detector.dart';
import 'apd_item.dart';

/// Skor minimum agar sebuah deteksi dianggap valid.
const _kMinConfidence = 0.5;

/// Berapa frame berturut-turut item boleh "hilang" sebelum dianggap
/// tidak terdeteksi (mencegah box berkedip).
const _kHoldFrames = 3;

const _emptyItems = [
  ApdItem(id: 'apron', name: 'Apron', isDetected: false),
  ApdItem(id: 'sepatu', name: 'Sepatu', isDetected: false),
  ApdItem(id: 'kacamata', name: 'Kacamata', isDetected: false),
  ApdItem(id: 'sarung_tangan', name: 'Sarung tangan', isDetected: false),
  ApdItem(id: 'helm_las', name: 'Helm las', isDetected: false),
];

class DeteksiState {
  const DeteksiState({
    required this.items,
    this.lokasi = 'Lingkungan Praktik',
    this.cameraActive = false,
  });

  final List<ApdItem> items;
  final String lokasi;
  final bool cameraActive;

  int get detectedCount => items.where((item) => item.isDetected).length;

  bool get isComplete => items.isNotEmpty && detectedCount == items.length;

  String get alertTitle {
    if (isComplete) return 'Semua APD terdeteksi';
    if (detectedCount == 0) return 'Belum ada APD terdeteksi';

    final missing = items.where((item) => !item.isDetected).toList();
    return '${missing.first.name} tidak terdeteksi';
  }

  String get alertMessage =>
      '$detectedCount dari ${items.length} APD wajib sudah terdeteksi';

  DeteksiState copyWith({
    List<ApdItem>? items,
    String? lokasi,
    bool? cameraActive,
  }) {
    return DeteksiState(
      items: items ?? this.items,
      lokasi: lokasi ?? this.lokasi,
      cameraActive: cameraActive ?? this.cameraActive,
    );
  }
}

class DeteksiNotifier extends Notifier<DeteksiState> {
  final Map<String, int> _misses = {};
  bool _processing = false;

  @override
  DeteksiState build() => const DeteksiState(items: _emptyItems);

  void setCameraActive(bool value) {
    state = state.copyWith(cameraActive: value);
    if (!value) _clear();
  }

  /// Dipanggil untuk setiap frame kamera (sudah di-throttle oleh kamera).
  Future<void> processFrame(
    CameraImage image, {
    required int rotation,
    required bool mirrored,
  }) async {
    if (_processing) return; // lewati frame jika model masih bekerja
    _processing = true;
    try {
      final detector = ref.read(apdDetectorProvider);
      final results = await detector.detect(
        image,
        rotation: rotation,
        mirrored: mirrored,
      );
      _apply(results);
    } catch (e, st) {
      debugPrint('Deteksi gagal: $e\n$st');
    } finally {
      _processing = false;
    }
  }

  void _apply(List<ApdDetection> results) {
    // Ambil deteksi dengan confidence tertinggi per jenis APD.
    final best = <String, ApdDetection>{};
    for (final d in results) {
      if (d.confidence < _kMinConfidence) continue;
      final cur = best[d.id];
      if (cur == null || d.confidence > cur.confidence) best[d.id] = d;
    }

    final next = state.items.map((item) {
      final hit = best[item.id];
      if (hit != null) {
        _misses[item.id] = 0;
        return ApdItem(
          id: item.id,
          name: item.name,
          isDetected: true,
          confidence: hit.confidence,
          box: hit.box,
        );
      }
      final miss = (_misses[item.id] ?? 0) + 1;
      _misses[item.id] = miss;
      if (item.isDetected && miss < _kHoldFrames) return item;
      return ApdItem(id: item.id, name: item.name, isDetected: false);
    }).toList();

    state = state.copyWith(items: List.unmodifiable(next));
  }

  void _clear() {
    _misses.clear();
    state = state.copyWith(items: _emptyItems);
  }

  void reset() => _clear();
}

final deteksiProvider = NotifierProvider<DeteksiNotifier, DeteksiState>(
  DeteksiNotifier.new,
);