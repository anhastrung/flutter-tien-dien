// pages/room_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/room.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  Future<void> _showDialog(AppProvider p, {Room? room}) async {
    final controller = TextEditingController(text: room?.name ?? '');

    await showDialog(
      context: context,
      barrierDismissible: !p.isCreatingRoom,
      builder: (_) {
        return Consumer<AppProvider>(
          builder: (_, provider, _) {
            return AlertDialog(
              title: Text(room == null ? 'Thêm phòng' : 'Sửa phòng'),
              content: TextField(
                controller: controller,
                enabled: !provider.isCreatingRoom,
                decoration: const InputDecoration(labelText: 'Tên phòng'),
              ),
              actions: [
                TextButton(
                  onPressed: provider.isCreatingRoom
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Huỷ'),
                ),
                TextButton(
                  onPressed: provider.isCreatingRoom
                      ? null
                      : () async {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;

                          if (room == null) {
                            // ❗ ĐÓNG MODAL TRƯỚC
                            Navigator.pop(context);
                            await provider.addRoom(name);
                          } else {
                            room.name = name;
                            Navigator.pop(context);
                            await provider.updateRoom(room);
                          }
                        },
                  child: provider.isCreatingRoom
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý phòng')),
      floatingActionButton: FloatingActionButton(
        onPressed: p.isCreatingRoom ? null : () => _showDialog(p),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: p.rooms.length,
        itemBuilder: (_, i) {
          final r = p.rooms[i];
          return Card(
            child: ListTile(
              title: Text(r.name),
              subtitle: Text(r.isOwnerRoom ? 'Chủ trọ' : 'Người thuê'),
              leading: Switch(
                value: r.isOwnerRoom,
                onChanged: (v) async {
                  r.isOwnerRoom = v;
                  await p.updateRoom(r);
                },
              ),
              onTap: () => _showDialog(p, room: r),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: p.isDeletingRoom ? null : () => p.deleteRoom(r.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
