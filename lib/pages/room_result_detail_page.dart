import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/electric_tier.dart';
import '../models/room_result.dart';
import '../providers/app_provider.dart';

class RoomResultDetailPage extends StatelessWidget {
  final RoomResult result;

  const RoomResultDetailPage({super.key, required this.result});

  String money(double v) => NumberFormat('#,###', 'vi').format(v.round());

  @override
  Widget build(BuildContext context) {
    final p = context.read<AppProvider>();

    final tiers = splitByTier(result.kwh, p.tiers);
    final subTotal = tiers.fold(0.0, (s, t) => s + t.money);
    final vatMoney = subTotal * p.vat;
    final totalMoney = subTotal + vatMoney;

    return Scaffold(
      appBar: AppBar(title: Text(result.room.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            const Divider(),

            ...tiers.map(
              (t) => row(
                'Bậc thang ${t.index}',
                money(t.price),
                t.kwh.toStringAsFixed(0),
                money(t.money),
              ),
            ),

            const SizedBox(height: 24),
            total('Tiền điện chưa thuế', money(subTotal)),
            const Divider(),
            total(
              'Thuế GTGT (${(p.vat * 100).toStringAsFixed(0)}%)',
              money(vatMoney),
            ),
            const Divider(),
            total(
              'Tổng cộng thanh toán',
              money(totalMoney),
              bold: true,
              red: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget header() => Row(
    children: const [
      Expanded(child: Text('')),
      Expanded(
        child: Text(
          'ĐƠN GIÁ',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: Text(
          'SẢN LƯỢNG',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: Text(
          'THÀNH TIỀN',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );

  Widget row(String label, String price, String kwh, String money) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Expanded(child: Text(price, textAlign: TextAlign.center)),
        Expanded(child: Text(kwh, textAlign: TextAlign.center)),
        Expanded(child: Text(money, textAlign: TextAlign.center)),
      ],
    ),
  );

  Widget total(
    String label,
    String value, {
    bool bold = false,
    bool red = false,
  }) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : null,
            color: red ? Colors.pink : null,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : null,
          color: red ? Colors.pink : null,
        ),
      ),
    ],
  );

  List<TierResult> splitByTier(double totalKwh, List<ElectricTier> tiers) {
    double remain = totalKwh;
    final List<TierResult> result = [];

    for (int i = 0; i < tiers.length; i++) {
      if (remain <= 0) break;
      final t = tiers[i];
      final range = t.to == double.infinity ? remain : t.to - t.from + 1;
      final used = remain > range ? range : remain;

      result.add(
        TierResult(
          index: i + 1,
          price: t.price,
          kwh: used,
          money: used * t.price,
        ),
      );

      remain -= used;
    }
    return result;
  }
}

class TierResult {
  final int index;
  final double price;
  final double kwh;
  final double money;

  TierResult({
    required this.index,
    required this.price,
    required this.kwh,
    required this.money,
  });
}
