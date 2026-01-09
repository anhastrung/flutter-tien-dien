import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/electric_result_firestore.dart';
import '../services/room_firestore.dart';
import '../models/room.dart';
import '../providers/app_provider.dart';
import 'electric_history_detail_page.dart';
import '../widgets/month_year_picker_dialog.dart';

class ElectricHistoryPage extends StatefulWidget {
  final String Function(num) money;

  const ElectricHistoryPage({super.key, required this.money});

  @override
  State<ElectricHistoryPage> createState() => _ElectricHistoryPageState();
}

class _ElectricHistoryPageState extends State<ElectricHistoryPage> {
  DateTime? from;
  DateTime? to;
  Room? pendingRoom;

  String lossOption = '';
  String roomId = '';

  String sortField = 'createdAt';
  bool desc = true;

  bool loading = false;
  bool searched = false;

  List<QueryDocumentSnapshot> results = [];

  // room select
  List<Room> rooms = [];
  Room? selectedRoom;
  bool loadingRooms = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    pendingRoom = selectedRoom;
  }

  Future<void> _loadRooms() async {
    final data = await RoomFirestore.getRooms();
    setState(() {
      rooms = data;
      loadingRooms = false;
    });
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => MonthYearPickerDialog(from: from, to: to, isFrom: isFrom),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          from = picked;
          if (to != null &&
              DateTime(
                from!.year,
                from!.month,
              ).isAfter(DateTime(to!.year, to!.month))) {
            to = null;
          }
        } else {
          to = picked;
          if (from != null &&
              DateTime(
                to!.year,
                to!.month,
              ).isBefore(DateTime(from!.year, from!.month))) {
            from = null;
          }
        }
      });
    }
  }

  Future<void> _search() async {
    setState(() {
      loading = true;
      searched = true;
      selectedRoom = pendingRoom;
      roomId = pendingRoom?.id ?? '';
    });

    final snap = await ElectricResultFirestore.search(
      from: from,
      to: to,
      lossOption: lossOption.isEmpty ? null : lossOption,
      sortField: sortField,
      desc: desc,
    );

    final filtered = roomId.isEmpty
        ? snap.docs
        : snap.docs.where((d) {
            final List details = d['details'] ?? [];
            return details.any((e) => e['roomId'] == roomId);
          }).toList();

    setState(() {
      results = filtered;
      loading = false;
    });
  }

  String _formatMonth(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử tiền điện')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bộ lọc',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range, size: 18),
                              onPressed: () => _pickDate(true),
                              label: Text(
                                from == null ? 'Từ tháng' : _formatMonth(from),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range, size: 18),
                              onPressed: () => _pickDate(false),
                              label: Text(
                                to == null ? 'Đến tháng' : _formatMonth(to),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (loadingRooms)
                      const LinearProgressIndicator()
                    else
                      DropdownButtonFormField<Room>(
                        initialValue: pendingRoom,
                        decoration: const InputDecoration(labelText: 'Phòng'),
                        items: [
                          const DropdownMenuItem<Room>(
                            value: null,
                            child: Text('Tất cả phòng'),
                          ),
                          ...rooms.map(
                            (r) => DropdownMenuItem<Room>(
                              value: r,
                              child: Text(r.name),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            pendingRoom = v;
                          });
                        },
                      ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<LossOption>(
                      decoration: const InputDecoration(
                        labelText: 'Tùy chọn tổn thất',
                      ),
                      items: [
                        const DropdownMenuItem<LossOption>(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        ...LossOption.values.map(
                          (o) => DropdownMenuItem<LossOption>(
                            value: o,
                            child: Text(o.name),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        lossOption = v?.title ?? '';
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: sortField,
                            decoration: const InputDecoration(
                              labelText: 'Sắp xếp theo',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'createdAt',
                                child: Text('Tháng'),
                              ),
                              DropdownMenuItem(
                                value: 'totalMoney',
                                child: Text('Tổng tiền'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => sortField = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            Switch(
                              value: desc,
                              onChanged: (v) => setState(() => desc = v),
                            ),
                            const Text('Giảm dần'),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Tìm kiếm'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (searched && !loading && results.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Không có dữ liệu'),
              ),

            if (searched && !loading && results.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final d = results[index];
                  if (roomId.isNotEmpty) {
                    final List details = d['details'] ?? [];
                    final detail = details.firstWhere(
                      (e) => e['roomId'] == roomId,
                      orElse: () => null,
                    );
                    if (detail != null) {
                      return ListTile(
                        title: Text(
                          'Phòng ${detail['roomName']} - Tháng ${d['month']}',
                        ),
                        trailing: Text(
                          '${widget.money(detail['money'])} đ',
                          style: const TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ElectricHistoryDetailPage(snapshot: d),
                            ),
                          );
                        },
                      );
                    }
                  }
                  return ListTile(
                    title: Text('Tháng ${d['month']}'),
                    trailing: Text(
                      '${widget.money(d['totalMoney'])} đ',
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ElectricHistoryDetailPage(snapshot: d),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
