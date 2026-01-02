import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/app_provider.dart';
import '../models/room_result.dart';
import 'room_result_detail_page.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  String money(double v) => NumberFormat('#,###', 'vi').format(v.round());

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final List<RoomResult> results = p.calculate();

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final r = results[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            title: Text(
              r.room.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${r.kwh.toStringAsFixed(0)} kWh'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${money(r.money)} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomResultDetailPage(result: r),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
