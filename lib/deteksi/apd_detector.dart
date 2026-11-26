import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'apd_item.dart';

/// Satu hasil deteksi dari model AI.
/// [id] harus salah satu: apron, sepatu, kacamata, sarung_tangan, helm_las.
class ApdDetection {
  const ApdDetection({
    required this.id,
    required this.confidence,
    required this.box,
  });

  final String id;
  final double confidence; // 0.0 - 1.0
  final ApdBoundingBox box;
}

/// Kontrak detektor. Implementasi nyata (TFLite/YOLO on-device atau API)
/// cukup mengisi [detect].
abstract class ApdDetector {
  Future<void> load();

  /// Jalankan model pada satu frame kamera.
  ///
  /// Box yang dikembalikan harus ternormalisasi 0..1 terhadap gambar TEGAK
  /// (setelah diputar sebesar [rotation] derajat). Jika [mirrored] true
  /// (kamera depan), balik sumbu X supaya cocok dengan preview.
  Future<List<ApdDetection>> detect(
    CameraImage image, {
    required int rotation,
    required bool mirrored,
  });

  void dispose();
}

/// Placeholder: belum ada model, jadi tidak mendeteksi apa pun.
/// Ganti dengan detektor sungguhan di [apdDetectorProvider].
class StubApdDetector implements ApdDetector {
  @override
  Future<void> load() async {}

  @override
  Future<List<ApdDetection>> detect(
    CameraImage image, {
    required int rotation,
    required bool mirrored,
  }) async =>
      const [];

  @override
  void dispose() {}
}

final apdDetectorProvider = Provider<ApdDetector>((ref) {
  final detector = StubApdDetector(); // TODO: ganti dengan model sungguhan
  detector.load();
  ref.onDispose(detector.dispose);
  return detector;
});