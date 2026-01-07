import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../expandable_section.dart';
import '../info_text.dart';

class LossOwnerSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onDone;

  const LossOwnerSection({
    super.key,
    required this.expanded,
    required this.onTap,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return ExpandableSection(
      title: 'Người chịu tổn thất điện năng',
      expanded: expanded,
      onTap: onTap,
      summary: Text('Đã chọn: ${p.lossOption.name}'),
      infoContent: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoText(
            title: 'Chia đều tất cả',
            description:
                'Phần điện năng hao hụt được chia cho tất cả các phòng.',
          ),
          SizedBox(height: 8),
          InfoText(
            title: 'Chủ trọ chịu',
            description: 'Toàn bộ phần điện năng hao hụt do chủ trọ chi trả.',
          ),
          SizedBox(height: 8),
          InfoText(
            title: 'Người thuê chịu',
            description:
                'Phần điện năng hao hụt được phân bổ cho các phòng thuê.',
          ),
        ],
      ),
      expandedChild: RadioGroup<LossOption>(
        groupValue: p.lossOption,
        onChanged: (v) {
          if (v != null) {
            p.setLossOption(v);
            onDone();
          }
        },
        child: Column(
          children: LossOption.values.map((e) {
            return RadioListTile(value: e, title: Text(e.name));
          }).toList(),
        ),
      ),
    );
  }
}
