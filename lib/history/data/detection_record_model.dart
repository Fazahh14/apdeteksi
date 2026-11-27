import 'package:apdeteksi/history/domain/detection_record.dart';

class DetectionRecordModel extends DetectionRecord {
  const DetectionRecordModel({
    required super.id,
    required super.detectedAt,
    required super.isComplete,
    required super.place,
    required super.detail,
  });

  factory DetectionRecordModel.fromMap(Map<String, dynamic> map) {
    return DetectionRecordModel(
      id: map['id'] as String,
      detectedAt: DateTime.parse(map['detected_at'] as String),
      isComplete: map['is_complete'] as bool,
      place: map['place'] as String,
      detail: map['detail'] as String,
    );
  }
}
