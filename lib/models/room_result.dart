import 'room.dart';

class RoomResult {
  final Room room;
  final double kwh;
  final double money;

  RoomResult({required this.room, required this.kwh, required this.money});

  Map<String, dynamic> toJson() {
    return {
      'roomId': room.id,
      'roomName': room.name,
      'isOwnerRoom': room.isOwnerRoom,
      'kwh': kwh,
      'money': money,
    };
  }

  factory RoomResult.fromJson(Map<String, dynamic> json) {
    return RoomResult(
      room: Room(
        id: json['roomId'],
        name: json['roomName'],
        isOwnerRoom: json['isOwnerRoom'],
      ),
      kwh: (json['kwh'] as num).toDouble(),
      money: (json['money'] as num).toDouble(),
    );
  }
}
