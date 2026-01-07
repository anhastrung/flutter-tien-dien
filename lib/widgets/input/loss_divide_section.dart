import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../expandable_section.dart';
import '../info_text.dart';

class LossDivideSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onDone;

  const LossDivideSection({
    super.key,
    required this.expanded,
    required this.onTap,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return ExpandableSection(
      title: 'Cách chia tiền tổn thất điện năng',
      expanded: expanded,
      onTap: onTap,
      summary: Text('Đã chọn: ${p.lossDivineOption.name}'),
      infoContent: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoText(
            title: 'Chia đều',
            description: 'Phần tiền điện tổn thất được chia đều cho các phòng.',
          ),
          SizedBox(height: 8),
          InfoText(
            title: 'Chia theo phần trăm',
            description:
                'Phần tiền điện tổn thất được chia theo tỷ lệ điện đã dùng.',
          ),
        ],
      ),
      expandedChild: RadioGroup<LossDivineOption>(
        groupValue: p.lossDivineOption,
        onChanged: (v) {
          if (v != null) {
            p.setLossDivineOption(v);
            onDone();
          }
        },
        child: Column(
          children: LossDivineOption.values.map((e) {
            return RadioListTile(value: e, title: Text(e.name));
          }).toList(),
        ),
      ),
    );
  }
}
