import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../expandable_section.dart';
import '../info_text.dart';

class RoomCounterSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  final TextEditingController Function(int, double) roomCtrl;

  const RoomCounterSection({
    super.key,
    required this.expanded,
    required this.onTap,
    required this.roomCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableSection(
          title: 'Counter phòng',
          expanded: expanded,
          onTap: onTap,
          infoContent: const InfoText(
            description: 'Chỉ số điện tiêu thụ của từng phòng.',
          ),
          summary: Text('Tổng: ${p.sumRoomCounter.toInt()} kWh'),
          expandedChild: Column(
            children: p.rooms.asMap().entries.map((e) {
              final r = e.value;
              final ctrl = roomCtrl(e.key, r.tempCounter);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, overflow: TextOverflow.ellipsis),
                          if (r.isOwnerRoom)
                            const Text(
                              '(Chủ phòng trọ)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: ctrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _decoration(),
                        onChanged: (v) {
                          p.updateTempCounter(r, double.tryParse(v) ?? 0);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        if (!p.isCounterValid)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Giá trị counter tổng phải lớn hơn counter các phòng!',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
      ],
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      suffixText: 'kWh',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
