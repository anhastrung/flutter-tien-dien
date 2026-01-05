import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomFirestore {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'room';

  static Future<List<Room>> getRooms() async {
    try {
      final snapshot = await _db.collection(_collection).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Room(
          id: doc.id,
          name: data['name'] ?? '',
          isOwnerRoom: data['isOwnerRoom'] ?? false,
        );
      }).toList();
    } on FirebaseException catch (e) {
      // QUAN TRỌNG: KHÔNG throw
      print('getRooms Firebase error: ${e.code}');
      return [];
    } catch (e) {
      print('getRooms unknown error: $e');
      return [];
    }
  }

  static Future<Room?> addRoom(String name) async {
    try {
      final docRef = await _db.collection(_collection).add({
        'name': name,
        'isOwnerRoom': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Room(id: docRef.id, name: name, isOwnerRoom: false);
    } on FirebaseException catch (e) {
      print('addRoom Firebase error: ${e.code}');
      return null;
    } catch (e) {
      print('addRoom unknown error: $e');
      return null;
    }
  }

  static Future<bool> updateRoom(Room room) async {
    try {
      await _db.collection(_collection).doc(room.id).update({
        'name': room.name,
        'isOwnerRoom': room.isOwnerRoom,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseException catch (e) {
      print('updateRoom Firebase error: ${e.code}');
      return false;
    } catch (e) {
      print('updateRoom unknown error: $e');
      return false;
    }
  }

  static Future<bool> deleteRoom(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
      return true;
    } on FirebaseException catch (e) {
      print('deleteRoom Firebase error: ${e.code}');
      return false;
    } catch (e) {
      print('deleteRoom unknown error: $e');
      return false;
    }
  }

  static Future<Room?> getRoomById(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Room(
        id: doc.id,
        name: data['name'] ?? '',
        isOwnerRoom: data['isOwnerRoom'] ?? false,
      );
    } on FirebaseException catch (e) {
      print('getRoomById Firebase error: ${e.code}');
      return null;
    } catch (e) {
      print('getRoomById unknown error: $e');
      return null;
    }
  }
}
