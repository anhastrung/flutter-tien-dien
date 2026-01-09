// pages/statistics_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/app_drawer.dart';
import '../widgets/month_year_picker_dialog.dart';
import '../services/electric_result_firestore.dart';
import '../services/room_firestore.dart';
import '../models/room.dart';
import '../providers/app_provider.dart';
import 'electric_history_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime? from;
  DateTime? to;

  Room? pendingRoom;
  Room? selectedRoom;

  String lossOption = '';

  bool loading = false;
  bool searched = false;

  List<QueryDocumentSnapshot> results = [];

  List<Room> rooms = [];
  bool loadingRooms = true;

  String money(num v) => NumberFormat('#,###', 'vi').format(v.round());

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _search(); // ✅ tự động load khi vào trang
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

  String _formatMonth(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  Future<void> _search() async {
    setState(() {
      loading = true;
      searched = true;
      selectedRoom = pendingRoom;
    });

    final snap = await ElectricResultFirestore.search(
      from: from,
      to: to,
      lossOption: lossOption.isEmpty ? null : lossOption,
      sortField: 'createdAt',
      desc: false,
    );

    final filtered = selectedRoom == null
        ? snap.docs
        : snap.docs.where((d) {
            final List details = d['details'] ?? [];
            return details.any((e) => e['roomId'] == selectedRoom!.id);
          }).toList();

    setState(() {
      results = filtered;
      loading = false;
    });
  }

  Map<String, num> _buildChartData() {
    final Map<String, num> map = {};

    for (final d in results) {
      final String month = d['month'];

      if (selectedRoom != null) {
        final List details = d['details'] ?? [];
        for (final e in details) {
          if (e['roomId'] == selectedRoom!.id) {
            map[month] = (map[month] ?? 0) + (e['money'] as num);
          }
        }
      } else {
        map[month] = (map[month] ?? 0) + (d['totalMoney'] as num);
      }
    }

    return map;
  }

  Widget _buildChart(Map<String, num> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Không có dữ liệu để vẽ biểu đồ'),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true),
                  spots: List.generate(
                    entries.length,
                    (i) => FlSpot(i.toDouble(), entries[i].value.toDouble()),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) => Text(
                      '${money(value)} đ',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) {
                        return const SizedBox();
                      }
                      final idx = value.toInt();
                      if (idx < 0 || idx >= entries.length) {
                        return const SizedBox();
                      }
                      return Text(
                        entries[idx].key,
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê điện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== FILTER =====
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
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 18),
                          onPressed: () => _pickDate(true),
                          label: Text(
                            from == null ? 'Từ tháng' : _formatMonth(from),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 18),
                          onPressed: () => _pickDate(false),
                          label: Text(
                            to == null ? 'Đến tháng' : _formatMonth(to),
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
                      onChanged: (v) => setState(() => pendingRoom = v),
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

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Lọc'),
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

          if (searched && !loading) _buildChart(_buildChartData()),

          const SizedBox(height: 24),

          // ===== XEM THÊM =====
          Row(
            children: [
              const Text(
                'Danh sách các tháng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ElectricHistoryPage(money: money),
                    ),
                  );
                },
                child: const Text('Xem thêm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
