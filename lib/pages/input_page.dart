// dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../widgets/app_drawer.dart';
import '../services/electric_result_firestore.dart';
import 'result_page.dart';

import '../widgets/input/total_counter_section.dart';
import '../widgets/input/room_counter_section.dart';
import '../widgets/input/loss_owner_section.dart';
//  import '../widgets/input/loss_divide_section.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  int? activeSection;
  bool saveResult = false;
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

  void _resetForm() {
    setState(() {
      totalCounterCtrl.clear();
      for (final c in roomCtrls.values) {
        c.clear();
      }
      saveResult = false;
      activeSection = null;
    });
    context.read<AppProvider>().resetForm(); // If you have a reset method
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
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            tooltip: 'Về trang chủ',
          ),
        ],
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
            TotalCounterSection(
              expanded: activeSection == 0,
              onTap: () {
                setState(() {
                  activeSection = activeSection == 0 ? null : 0;
                });
              },
              controller: totalCounterCtrl,
              debounce: debounce,
              onDebounceChange: (t) => debounce = t,
            ),

            const SizedBox(height: 24),

            RoomCounterSection(
              expanded: activeSection == 1,
              onTap: () {
                setState(() {
                  activeSection = activeSection == 1 ? null : 1;
                });
              },
              roomCtrl: _roomCtrl,
            ),

            const Divider(height: 32),

            LossOwnerSection(
              expanded: activeSection == 2,
              onTap: () {
                setState(() {
                  activeSection = activeSection == 2 ? null : 2;
                });
              },
              onDone: () => setState(() => activeSection = null),
            ),

            // const Divider(height: 32),

            // LossDivideSection(
            //   expanded: activeSection == 3,
            //   onTap: () {
            //     setState(() {
            //       activeSection = activeSection == 3 ? null : 3;
            //     });
            //   },
            //   onDone: () => setState(() => activeSection = null),
            // ),
            const SizedBox(height: 16),

            CheckboxListTile(
              value: saveResult,
              onChanged: (v) => setState(() => saveResult = v ?? true),
              title: const Text('Lưu kết quả tính'),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 80), // Add space for floating button
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: _resetForm,
            tooltip: 'Đặt lại',
            mini: true,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 200,
            height: 56,
            child: ElevatedButton(
              onPressed: p.isTotalCounterValid && p.isCounterValid
                  ? () async {
                      FocusScope.of(context).unfocus();

                      final results = p.calculate();

                      if (saveResult) {
                        final now = DateTime.now();
                        final month =
                            '${now.year}-${now.month.toString().padLeft(2, '0')}';

                        await ElectricResultFirestore.saveResult(
                          month: month,
                          results: results,
                          lossOption: p.lossOption.title,
                        );
                      }

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResultPage()),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Tính tiền điện',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
