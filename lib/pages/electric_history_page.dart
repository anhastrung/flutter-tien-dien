import 'package:flutter/material.dart';
import 'electric_history_detail_page.dart';

class ElectricHistoryPage extends StatelessWidget {
  final List docs;
  final String Function(num) money;

  const ElectricHistoryPage({
    super.key,
    required this.docs,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final d = docs[index];
        return ListTile(
          title: Text('Tháng ${d['month']}'),
          trailing: Text(
            '${money(d['totalMoney'])} đ',
            style: const TextStyle(color: Colors.red),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ElectricHistoryDetailPage(snapshot: docs[index]),
              ),
            );
          },
        );
      },
    );
  }
}
