import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../expandable_section.dart';
import '../info_text.dart';

class TotalCounterSection extends StatefulWidget {
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
  State<TotalCounterSection> createState() => _TotalCounterSectionState();
}

class _TotalCounterSectionState extends State<TotalCounterSection> {
  bool _dirty = false;
  late FocusNode _focusNode;
  bool _wasFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _wasFocused = true;
    } else if (_wasFocused && !_dirty) {
      setState(() {
        _dirty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableSection(
          title: 'Counter tổng',
          expanded: widget.expanded,
          onTap: widget.onTap,
          infoContent: const InfoText(
            description: 'Chỉ số điện từ công tơ chính của toàn bộ nhà.',
          ),
          summary: p.totalCounter > 0
              ? Text('Đã nhập: ${p.totalCounter.toInt()} kWh')
              : const Text('Chưa nhập'),
          expandedChild: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _decoration(),
            onChanged: (v) {
              widget.debounce?.cancel();
              widget.onDebounceChange(
                Timer(const Duration(milliseconds: 80), () {
                  p.setTotalCounter(double.tryParse(v) ?? 0);
                }),
              );
            },
          ),
        ),
        if (_dirty && !p.isTotalCounterValid)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Giá trị counter tổng trống',
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
