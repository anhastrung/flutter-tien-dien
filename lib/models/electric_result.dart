import 'room.dart';
import 'room_result.dart';

class ElectricResult {
  final String id;
  final String month; // yyyy-MM
  final DateTime createdAt;
  final double totalMoney;
  final List<RoomResult> details;

  ElectricResult({
    required this.id,
    required this.month,
    required this.createdAt,
    required this.totalMoney,
    required this.details,
  });

  factory ElectricResult.fromMap(String id, Map<String, dynamic> data) {
    return ElectricResult(
      id: id,
      month: data['month'] ?? 'unknown',
      createdAt: data['createdAt'] == null
          ? DateTime.now()
          : (data['createdAt'] as dynamic).toDate(),
      totalMoney: (data['totalMoney'] as num?)?.toDouble() ?? 0,
      details: (data['details'] as List? ?? []).map((e) {
        return RoomResult(
          room: Room(
            id: e['roomId'] ?? '',
            name: e['roomName'] ?? '',
            isOwnerRoom: e['isOwnerRoom'] ?? false,
          ),
          kwh: (e['kwh'] as num?)?.toDouble() ?? 0,
          money: (e['money'] as num?)?.toDouble() ?? 0,
        );
      }).toList(),
    );
  }
}
