import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomFirestore {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'room';

  static Future<List<Room>> getRooms() async {
    final snapshot = await _db.collection(_collection).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Room(
        id: doc.id,
        name: data['name'] ?? '',
        isOwnerRoom: data['isOwnerRoom'] ?? false,
      );
    }).toList();
  }

  static Future<Room> addRoom(String name) async {
    final docRef = await _db.collection(_collection).add({
      'name': name,
      'isOwnerRoom': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return Room(id: docRef.id, name: name, isOwnerRoom: false);
  }

  static Future<void> updateRoom(Room room) async {
    await _db.collection(_collection).doc(room.id).update({
      'name': room.name,
      'isOwnerRoom': room.isOwnerRoom,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteRoom(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  static Future<Room?> getRoomById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      isOwnerRoom: data['isOwnerRoom'] ?? false,
    );
  }
}
