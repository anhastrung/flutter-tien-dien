// services/electric_result_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_result.dart';

class ElectricResultFirestore {
  static final _ref = FirebaseFirestore.instance.collection('electric_results');

  static Future<void> saveResult({
    required String month,
    required List<RoomResult> results,
    required String lossOption,
  }) async {
    final totalMoney = results.fold<double>(0, (s, r) => s + r.money);
    await _ref.add({
      'month': month,
      'totalMoney': totalMoney,
      'createdAt': Timestamp.now(),
      'details': results.map((e) => e.toJson()).toList(),
      'LossOption': lossOption,
    });
  }

  static Stream<QuerySnapshot> streamAll() {
    return _ref.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<QuerySnapshot> search({
    DateTime? from,
    DateTime? to,
    String? lossOption = '',
    String sortField = 'createdAt',
    bool desc = true,
  }) async {
    Query q = _ref;

    if (lossOption != null && lossOption.isNotEmpty) {
      q = q.where('LossOption', isEqualTo: lossOption);
    }

    if (from != null) {
      q = q.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }

    if (to != null) {
      q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }

    q = q.orderBy(sortField, descending: desc);

    return await q.get();
  }
}
