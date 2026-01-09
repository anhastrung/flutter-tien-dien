import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/app_provider.dart';

class ElectricPricePage extends StatelessWidget {
  const ElectricPricePage({super.key});

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    return formatter.format(value);
  }

  double parseCurrency(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    Timer? debounce;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giá điện & VAT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            tooltip: 'Về trang chủ',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: p.tiers.length,
                itemBuilder: (_, i) {
                  final t = p.tiers[i];
                  final controller = TextEditingController(
                    text: formatCurrency(t.price),
                  );

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.to == double.infinity
                              ? '> ${t.from.toInt()} kWh'
                              : '${t.from.toInt()} - ${t.to.toInt()} kWh',
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(suffix: Text('đ')),
                          onChanged: (v) {
                            if (debounce?.isActive ?? false) debounce!.cancel();
                            debounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                p.updateTier(i, parseCurrency(v));
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                const Text('VAT %'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: (p.vat * 100).toStringAsFixed(0),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (v) {
                      final parsed = double.tryParse(v);
                      if (parsed != null) {
                        p.updateVat(parsed / 100);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
