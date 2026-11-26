class ApdBoundingBox {
  const ApdBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// Koordinat ternormalisasi 0.0–1.0 terhadap area preview kamera.
  final double left;
  final double top;
  final double width;
  final double height;
}

class ApdItem {
  const ApdItem({
    required this.id,
    required this.name,
    required this.isDetected,
    this.confidence,
    this.box,
  });

  final String id;
  final String name;
  final bool isDetected;
  final double? confidence;
  final ApdBoundingBox? box;

  String get confidenceCompact {
    if (!isDetected || confidence == null) return 'Belum terdeteksi';
    return '${(confidence! * 100).round()} %';
  }

  String get boxLabel {
    switch (id) {
      case 'apron':
        return 'Apron';
      case 'sepatu':
        return 'Sepatu';
      case 'kacamata':
        return 'Kacamata';
      case 'sarung_tangan':
        return 'Sarung tangan';
      case 'helm_las':
        return 'Helm las';
      default:
        return name;
    }
  }

  ApdItem copyWith({
    bool? isDetected,
    double? confidence,
    ApdBoundingBox? box,
    bool clearBox = false,
  }) {
    return ApdItem(
      id: id,
      name: name,
      isDetected: isDetected ?? this.isDetected,
      confidence: confidence ?? this.confidence,
      box: clearBox ? null : (box ?? this.box),
    );
  }
}
