import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/room_result.dart';
import '../models/electric_tier.dart';
import '../services/room_firestore.dart';
import '../services/electric_calc_service.dart';

enum LossOption {
  splitAll('Chia đều'),
  ownerPay('Chủ trọ'),
  tenantPay('Người thuê');

  final String name;
  const LossOption(this.name);
}

enum LossDivineOption {
  splitAll('Chia đều'),
  splitByPercent('Chia theo % điện đã dùng');

  final String name;
  const LossDivineOption(this.name);
}

class AppProvider extends ChangeNotifier {
  double _totalCounter = 0;
  double get totalCounter => _totalCounter;

  double vat = 0.08;

  LossOption lossOption = LossOption.splitAll;
  LossDivineOption lossDivineOption = LossDivineOption.splitAll;

  bool isLoadingRooms = false;
  bool isCreatingRoom = false;
  bool isUpdatingRoom = false;
  bool isDeletingRoom = false;

  final List<Room> rooms = [];

  final List<ElectricTier> tiers = [
    ElectricTier(from: 0, to: 50, price: 1984),
    ElectricTier(from: 51, to: 100, price: 2050),
    ElectricTier(from: 101, to: 200, price: 2380),
    ElectricTier(from: 201, to: 300, price: 2998),
    ElectricTier(from: 301, to: 400, price: 3350),
    ElectricTier(from: 401, to: double.infinity, price: 3460),
  ];

  double get sumRoomCounter => rooms.fold(0, (sum, r) => sum + r.tempCounter);

  bool get isCounterValid => sumRoomCounter <= totalCounter;

  void setTotalCounter(double value) {
    _totalCounter = value;
    notifyListeners();
  }

  Future<void> loadRooms() async {
    if (isLoadingRooms) return;

    isLoadingRooms = true;
    notifyListeners();

    try {
      final data = await RoomFirestore.getRooms();
      rooms
        ..clear()
        ..addAll(data);
    } finally {
      isLoadingRooms = false;
      notifyListeners();
    }
  }

  Future<void> addRoom(String name) async {
    if (isCreatingRoom) return;

    isCreatingRoom = true;

    final tempRoom = Room(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      isOwnerRoom: false,
    );

    rooms.add(tempRoom);
    notifyListeners();

    try {
      final realRoom = await RoomFirestore.addRoom(name);
      final index = rooms.indexWhere((r) => r.id == tempRoom.id);
      if (index != -1) {
        rooms[index] = realRoom;
      }
    } catch (e) {
      rooms.removeWhere((r) => r.id == tempRoom.id);
      rethrow;
    } finally {
      isCreatingRoom = false;
      notifyListeners();
    }
  }

  Future<void> updateRoom(Room room) async {
    if (isUpdatingRoom) return;

    isUpdatingRoom = true;
    notifyListeners();

    try {
      await RoomFirestore.updateRoom(room);
    } finally {
      isUpdatingRoom = false;
      notifyListeners();
    }
  }

  Future<void> deleteRoom(String id) async {
    if (isDeletingRoom) return;

    isDeletingRoom = true;

    final index = rooms.indexWhere((r) => r.id == id);
    if (index == -1) {
      isDeletingRoom = false;
      return;
    }

    final removed = rooms.removeAt(index);
    notifyListeners();

    try {
      await RoomFirestore.deleteRoom(id);
    } catch (e) {
      rooms.insert(index, removed);
      rethrow;
    } finally {
      isDeletingRoom = false;
      notifyListeners();
    }
  }

  void updateTempCounter(Room room, double value) {
    room.tempCounter = value;
    notifyListeners();
  }

  void setLossOption(LossOption option) {
    lossOption = option;
    notifyListeners();
  }

  void setLossDivineOption(LossDivineOption option) {
    lossDivineOption = option;
    notifyListeners();
  }

  void updateVat(double value) {
    vat = value;
    notifyListeners();
  }

  void updateTier(int index, double price) {
    tiers[index] = ElectricTier(
      from: tiers[index].from,
      to: tiers[index].to,
      price: price,
    );
    notifyListeners();
  }

  List<RoomResult> calculate() {
    final roomSumElectric = rooms.fold(0.0, (sum, r) => sum + r.tempCounter);

    final lossElectric = (totalCounter - roomSumElectric).clamp(
      0,
      double.infinity,
    );

    List<Room> lossRooms;
    switch (lossOption) {
      case LossOption.ownerPay:
        lossRooms = rooms.where((r) => r.isOwnerRoom).toList();
        break;
      case LossOption.tenantPay:
        lossRooms = rooms.where((r) => !r.isOwnerRoom).toList();
        break;
      case LossOption.splitAll:
        lossRooms = rooms;
        break;
    }

    final activeRooms = lossRooms.where((r) => r.tempCounter > 0).toList();
    final activeSum = activeRooms.fold(0.0, (s, r) => s + r.tempCounter);

    return rooms.map((room) {
      double lossKwh = 0;

      if (lossElectric > 0 && activeRooms.contains(room)) {
        if (lossDivineOption == LossDivineOption.splitAll) {
          lossKwh = lossElectric / activeRooms.length;
        } else {
          lossKwh = activeSum == 0
              ? 0
              : lossElectric * room.tempCounter / activeSum;
        }
      }

      final totalKwh = room.tempCounter + lossKwh;
      final money = calcPrice(totalKwh, tiers) * (1 + vat);

      return RoomResult(room: room, kwh: totalKwh, money: money);
    }).toList();
  }
}
