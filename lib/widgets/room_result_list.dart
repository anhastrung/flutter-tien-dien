// widgets/room_result_list.dart
import 'package:flutter/material.dart';
import '../models/room_result.dart';
import '../pages/room_result_detail_page.dart';
import 'package:intl/intl.dart';

class RoomResultList extends StatelessWidget {
  final List<RoomResult> results;
  final bool showArrow;

  const RoomResultList({
    super.key,
    required this.results,
    this.showArrow = false,
  });

  String money(double v) => NumberFormat('#,###', 'vi').format(v.round());

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (r.room.isOwnerRoom)
                const Text(
                  '(Chủ phòng trọ)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              Text('${r.kwh.toStringAsFixed(0)} kWh'),
            ],
          ),
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
              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
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
    );
  }
}
