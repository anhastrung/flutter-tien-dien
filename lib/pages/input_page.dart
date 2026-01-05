// pages/input_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/app_provider.dart';
import 'result_page.dart';

class InfoText extends StatelessWidget {
  final String? title;
  final String description;

  const InfoText({super.key, this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    if (title == null || title!.isEmpty) {
      return Text(description);
    }
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: description),
        ],
      ),
    );
  }
}

class ExpandableSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final Widget expandedChild;
  final Widget? summary;
  final Widget? infoContent;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.expandedChild,
    this.summary,
    this.infoContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    if (infoContent != null)
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(title),
                              content: infoContent,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Đã hiểu'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    Icon(expanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),

                if (!expanded && summary != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: DefaultTextStyle(
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                      child: summary!,
                    ),
                  ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Visibility(
            visible: expanded,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: expandedChild,
            ),
          ),
        ),
      ],
    );
  }
}

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  int? activeSection;
  Timer? debounce;

  late TextEditingController totalCounterCtrl;
  final Map<int, TextEditingController> roomCtrls = {};

  @override
  void initState() {
    super.initState();
    totalCounterCtrl = TextEditingController();
  }

  @override
  void dispose() {
    totalCounterCtrl.dispose();
    for (final c in roomCtrls.values) {
      c.dispose();
    }
    debounce?.cancel();
    super.dispose();
  }

  TextEditingController _roomCtrl(int index, double value) {
    return roomCtrls.putIfAbsent(
      index,
      () => TextEditingController(
        text: value > 0 ? value.toInt().toString() : '',
      ),
    );
  }

  InputDecoration _counterDecoration(String label) {
    return InputDecoration(
      labelText: label.isEmpty ? null : label,
      suffixText: 'kWh',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    if (p.isLoadingRooms) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tính tiền điện'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => activeSection = null);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ExpandableSection(
              title: 'Counter tổng',
              expanded: activeSection == 0,
              onTap: () {
                setState(() {
                  activeSection = activeSection == 0 ? null : 0;
                });
              },
              infoContent: const InfoText(
                description: 'Chỉ số điện từ công tơ chính của toàn bộ nhà.',
              ),
              summary: p.totalCounter > 0
                  ? Text('Đã nhập: ${p.totalCounter.toInt()} kWh')
                  : const Text('Chưa nhập'),
              expandedChild: TextField(
                controller: totalCounterCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _counterDecoration('Counter tổng'),
                onChanged: (v) {
                  debounce?.cancel();
                  debounce = Timer(
                    const Duration(milliseconds: 80),
                    () => p.setTotalCounter(double.tryParse(v) ?? 0),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            ExpandableSection(
              title: 'Counter phòng',
              expanded: activeSection == 1,
              onTap: () {
                setState(() {
                  activeSection = activeSection == 1 ? null : 1;
                });
              },
              infoContent: const InfoText(
                description: 'Chỉ số điện tiêu thụ của từng phòng.',
              ),
              summary: Text('Tổng: ${p.sumRoomCounter.toInt()} kWh'),
              expandedChild: Column(
                children: [
                  ...p.rooms.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final r = entry.value;
                    final ctrl = _roomCtrl(idx, r.tempCounter);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.name,
                              overflow: TextOverflow.ellipsis,
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
                              decoration: _counterDecoration(''),
                              onChanged: (v) {
                                p.updateTempCounter(r, double.tryParse(v) ?? 0);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            if (!p.isCounterValid)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'Giá trị counter tổng phải lớn hơn counter các phòng!',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            const Divider(height: 32),

            ExpandableSection(
              title: 'Người chịu tổn thất điện năng',
              expanded: activeSection == 2,
              onTap: () {
                setState(() {
                  activeSection = activeSection == 2 ? null : 2;
                });
              },
              infoContent: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  InfoText(
                    title: 'Chia đều tất cả',
                    description:
                        'Phần điện năng hao hụt được chia cho tất cả các phòng, kể cả chủ trọ.',
                  ),
                  SizedBox(height: 8),
                  InfoText(
                    title: 'Chủ trọ chịu',
                    description:
                        'Toàn bộ phần điện năng hao hụt do chủ trọ chi trả.',
                  ),
                  SizedBox(height: 8),
                  InfoText(
                    title: 'Người thuê chịu',
                    description:
                        'Phần điện năng hao hụt được phân bổ cho các phòng thuê.',
                  ),
                ],
              ),
              summary: Text('Đã chọn: ${p.lossOption.name}'),
              expandedChild: RadioGroup<LossOption>(
                groupValue: p.lossOption,
                onChanged: (v) {
                  if (v != null) {
                    p.setLossOption(v);
                    setState(() => activeSection = null);
                  }
                },
                child: Column(
                  children: LossOption.values
                      .map((e) => RadioListTile(value: e, title: Text(e.name)))
                      .toList(),
                ),
              ),
            ),

            const Divider(height: 32),

            ExpandableSection(
              title: 'Cách chia tiền tổn thất điện năng',
              expanded: activeSection == 3,
              onTap: () {
                setState(() {
                  activeSection = activeSection == 3 ? null : 3;
                });
              },
              infoContent: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  InfoText(
                    title: 'Chia đều',
                    description:
                        'Phần tiền điện tổn thất được chia đều cho tất cả các phòng sử dụng điện.',
                  ),
                  SizedBox(height: 8),
                  InfoText(
                    title: 'Chia theo phần trăm điện đã dùng',
                    description:
                        'Phần tiền điện tổn thất được chia theo tỷ lệ phần trăm điện năng đã sử dụng của từng phòng.',
                  ),
                ],
              ),
              summary: Text('Đã chọn: ${p.lossDivineOption.name}'),
              expandedChild: RadioGroup<LossDivineOption>(
                groupValue: p.lossDivineOption,
                onChanged: (v) {
                  if (v != null) {
                    p.setLossDivineOption(v);
                    setState(() => activeSection = null);
                  }
                },
                child: Column(
                  children: LossDivineOption.values
                      .map((e) => RadioListTile(value: e, title: Text(e.name)))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: p.isCounterValid
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResultPage()),
                      )
                    : null,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Tính tiền điện',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
