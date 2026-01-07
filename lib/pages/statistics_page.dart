import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'electric_history_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  String money(num v) => NumberFormat('#,###', 'vi').format(v.round());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê điện')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.blue,
        tooltip: 'Về trang chủ',
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('electric_results')
            .orderBy('month', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu'));
          }

          final Map<String, num> monthTotals = {};

          for (final d in docs) {
            final String month = d['month'] ?? '';
            final num total = (d['totalMoney'] ?? 0) as num;

            if (monthTotals.containsKey(month)) {
              monthTotals[month] = monthTotals[month]! + total;
            } else {
              monthTotals[month] = total;
            }
          }
          final chartData =
              monthTotals.entries
                  .map((e) => {'month': e.key, 'total': e.value.round()})
                  .toList()
                ..sort((a, b) {
                  final am = a['month'] as String? ?? '';
                  final bm = b['month'] as String? ?? '';
                  return am.compareTo(bm);
                });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Biểu đồ tổng tiền điện theo tháng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  '${money(spot.y)} đ',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        minY: 0,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              chartData.length,
                              (i) => FlSpot(
                                i.toDouble(),
                                (chartData[i]['total'] as num).toDouble(),
                              ),
                            ),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            belowBarData: BarAreaData(show: true),
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 48,
                              getTitlesWidget: (value, meta) => Text(
                                '${money(value)} đ',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0) {
                                  return const SizedBox();
                                }

                                final idx = value.toInt();
                                if (idx < 0 || idx >= chartData.length) {
                                  return const SizedBox();
                                }

                                return Text(
                                  chartData[idx]['month'].toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),

                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Danh sách các tháng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ElectricHistoryPage(docs: docs, money: money),
            ],
          );
        },
      ),
    );
  }
}
