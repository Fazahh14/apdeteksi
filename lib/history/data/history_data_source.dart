import 'package:apdeteksi/history/data/detection_record_model.dart';

abstract class HistoryDataSource {
  Future<List<DetectionRecordModel>> fetchRecords();
}

/// Data contoh. Ganti dengan implementasi asli (API / SQLite / Firebase).
class HistoryMockDataSource implements HistoryDataSource {
  @override
  Future<List<DetectionRecordModel>> fetchRecords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final n = DateTime.now();
    String at(int dayOffset, int h, int m) =>
        DateTime(n.year, n.month, n.day - dayOffset, h, m).toIso8601String();

    final raw = <Map<String, dynamic>>[
      {'id': '1', 'detected_at': at(0, 8, 42), 'is_complete': true, 'place': 'Gudang B', 'detail': '4 dari 4 APD terdeteksi'},
      {'id': '2', 'detected_at': at(0, 8, 15), 'is_complete': false, 'place': 'Jalur Perakitan', 'detail': 'Sepatu tidak terdeteksi'},
      {'id': '3', 'detected_at': at(0, 7, 50), 'is_complete': true, 'place': 'Area Bongkar', 'detail': '4 dari 4 APD terdeteksi'},
      {'id': '4', 'detected_at': at(1, 16, 30), 'is_complete': false, 'place': 'Gudang A', 'detail': 'Sarung tangan terlewat'},
      {'id': '5', 'detected_at': at(1, 14, 10), 'is_complete': true, 'place': 'Area Las', 'detail': '4 dari 4 APD terdeteksi'},
    ];
    return raw.map(DetectionRecordModel.fromMap).toList();
  }
}
