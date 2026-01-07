// pages/result_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../widgets/room_result_list.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final results = p.calculate();

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả')),
      body: RoomResultList(results: results, showArrow: true),
    );
  }
}
