import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../expandable_section.dart';
import '../info_text.dart';

class TotalCounterSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  final TextEditingController controller;
  final Timer? debounce;
  final void Function(Timer?) onDebounceChange;

  const TotalCounterSection({
    super.key,
    required this.expanded,
    required this.onTap,
    required this.controller,
    required this.debounce,
    required this.onDebounceChange,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return ExpandableSection(
      title: 'Counter tổng',
      expanded: expanded,
      onTap: onTap,
      infoContent: const InfoText(
        description: 'Chỉ số điện từ công tơ chính của toàn bộ nhà.',
      ),
      summary: p.totalCounter > 0
          ? Text('Đã nhập: ${p.totalCounter.toInt()} kWh')
          : const Text('Chưa nhập'),
      expandedChild: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _decoration(),
        onChanged: (v) {
          debounce?.cancel();
          onDebounceChange(
            Timer(const Duration(milliseconds: 80), () {
              p.setTotalCounter(double.tryParse(v) ?? 0);
            }),
          );
        },
      ),
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
