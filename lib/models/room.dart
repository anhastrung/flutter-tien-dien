import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  String name;
  bool isOwnerRoom;
  double tempCounter = 0;

  Room({required this.id, required this.name, required this.isOwnerRoom});

  factory Room.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'],
      isOwnerRoom: data['isOwnerRoom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'isOwnerRoom': isOwnerRoom};
}
