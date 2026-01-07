import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_result.dart';

class ElectricResultFirestore {
  static final _ref = FirebaseFirestore.instance.collection('electric_results');

  static Future<void> saveResult({
    required String month,
    required List<RoomResult> results,
  }) async {
    final totalMoney = results.fold<double>(0, (s, r) => s + r.money);
    await _ref.add({
      'month': month,
      'totalMoney': totalMoney,
      'createdAt': Timestamp.now(),
      'details': results.map((e) => e.toJson()).toList(),
    });
  }

  static Stream<QuerySnapshot> streamAll() {
    return _ref.orderBy('month', descending: true).snapshots();
  }
}
