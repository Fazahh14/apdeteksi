class DetectionRecord {
  final String id;
  final DateTime detectedAt;
  final bool isComplete;
  final String place;
  final String detail;

  const DetectionRecord({
    required this.id,
    required this.detectedAt,
    required this.isComplete,
    required this.place,
    required this.detail,
  });
}

enum HistoryFilter { all, complete, incomplete }
