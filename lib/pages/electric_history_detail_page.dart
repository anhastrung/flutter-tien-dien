// pages/electric_history_detail_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/room.dart';
import '../models/room_result.dart';
import '../widgets/room_result_list.dart';

class ElectricHistoryDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot snapshot;

  const ElectricHistoryDetailPage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final List details = snapshot['details'];

    final results = details.map<RoomResult>((e) {
      return RoomResult(
        room: Room(
          id: e['roomId'],
          name: e['roomName'],
          isOwnerRoom: e['isOwnerRoom'],
        ),
        kwh: (e['kwh'] as num).toDouble(),
        money: (e['money'] as num).toDouble(),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Kết quả tháng ${snapshot['month']}')),
      body: RoomResultList(results: results),
    );
  }
}
