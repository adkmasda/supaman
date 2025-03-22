import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('sales').listenable(),
        builder: (context, box, _) {
          final sales = box.values.toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Row
                Row(
                  children: [
                    _buildSummaryCard(
                      'Today\'s Sales',
                      _calculateDailySales(sales),
                      Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      'Weekly Sales',
                      _calculateWeeklySales(sales),
                      Colors.purple,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      'Monthly Sales',
                      _calculateMonthlySales(sales),
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Today's Transactions List
                const Text(
                  'Today\'s Transactions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _getTodaysSales(sales).length,
                    itemBuilder: (context, index) {
                      final sale = _getTodaysSales(sales)[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Text(
                                DateFormat('MMM dd, hh:mm a')
                                    .format(DateTime.parse(sale['timestamp'])),
                              ),
                              const Spacer(),
                              Text(
                                '₱${sale['total'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cashier: ${sale['cashier']}'),
                              Text('Customer: ${sale['customerName']}'),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const Text(
                                    'Items:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...sale['items']
                                      .map<Widget>((item) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: Row(
                                              children: [
                                                Text(
                                                    '${item['quantity']}x ${item['name']}'),
                                                const Spacer(),
                                                Text(
                                                    '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                                              ],
                                            ),
                                          )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₱${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDailySales(List sales) {
    final today = DateTime.now();
    return sales.where((sale) {
      final saleDate = DateTime.parse(sale['timestamp']);
      return saleDate.year == today.year &&
          saleDate.month == today.month &&
          saleDate.day == today.day;
    }).fold(0.0, (sum, sale) => sum + (sale['total'] as num));
  }

  double _calculateMonthlySales(List sales) {
    final today = DateTime.now();
    return sales.where((sale) {
      final saleDate = DateTime.parse(sale['timestamp']);
      return saleDate.year == today.year && saleDate.month == today.month;
    }).fold(0.0, (sum, sale) => sum + (sale['total'] as num));
  }

  List _getTodaysSales(List sales) {
    final today = DateTime.now();
    return sales.where((sale) {
      final saleDate = DateTime.parse(sale['timestamp']);
      return saleDate.year == today.year &&
          saleDate.month == today.month &&
          saleDate.day == today.day;
    }).toList();
  }

  double _calculateWeeklySales(List sales) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return sales.where((sale) {
      final saleDate = DateTime.parse(sale['timestamp']);
      return saleDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          saleDate.isBefore(now.add(const Duration(days: 1)));
    }).fold(0.0, (sum, sale) => sum + (sale['total'] as num));
  }
}
