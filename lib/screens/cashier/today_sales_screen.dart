import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TodaySalesScreen extends StatelessWidget {
  final String cashierName;

  const TodaySalesScreen({
    super.key,
    required this.cashierName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Sales'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('sales').listenable(),
        builder: (context, box, _) {
          final today = DateTime.now();
          final todaySales = box.values.where((sale) {
            final saleDate = DateTime.parse(sale['timestamp']);
            return saleDate.year == today.year &&
                saleDate.month == today.month &&
                saleDate.day == today.day &&
                sale['cashier'] == cashierName;
          }).toList();

          if (todaySales.isEmpty) {
            return const Center(
              child: Text('No sales today'),
            );
          }

          double totalSales = 0;
          int totalItems = 0;

          for (var sale in todaySales) {
            totalSales += sale['total'] as double;
            for (var item in sale['items']) {
              totalItems += item['quantity'] as int;
            }
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Sales',
                        '₱${totalSales.toStringAsFixed(2)}',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Items Sold',
                        totalItems.toString(),
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todaySales.length,
                  itemBuilder: (context, index) {
                    final sale = todaySales[index];
                    return Card(
                      child: ExpansionTile(
                        title: Text(
                          DateFormat('hh:mm a').format(
                            DateTime.parse(sale['timestamp']),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer: ${sale['customerName']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Total: ₱${sale['total'].toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sale['items'].length,
                            itemBuilder: (context, itemIndex) {
                              final item = sale['items'][itemIndex];
                              return ListTile(
                                title: Text(item['name']),
                                trailing: Text(
                                  '${item['quantity']} × ₱${item['price'].toStringAsFixed(2)}',
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Payment Details:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        'Amount Paid: ₱${sale['amountPaid'].toStringAsFixed(2)}'),
                                    Text(
                                      'Change: ₱${(sale['amountPaid'] - sale['total']).toStringAsFixed(2)}',
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
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
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
