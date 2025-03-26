import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'widgets/filter_bottom_sheet.dart'; // Make sure to create this file

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String selectedDatePreset = 'Today';
  String? selectedCategory;
  String? selectedProduct;
  String? selectedPaymentMethod;
  String? selectedCashier;
  String sortBy = 'Date';
  bool sortAscending = false;
  String analysisView = 'Transactions';
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day);
    endDate = now;
  }

  double _calculateDailySales(List<dynamic> sales) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return sales
        .where((sale) =>
            DateTime.parse(sale['timestamp']).isAfter(today) ||
            DateTime.parse(sale['timestamp']).isAtSameMomentAs(today))
        .fold(0.0, (sum, sale) => sum + (sale['total'] as num));
  }

  double _calculateWeeklySales(List<dynamic> sales) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    return sales
        .where((sale) => DateTime.parse(sale['timestamp']).isAfter(startOfWeek))
        .fold(0.0, (sum, sale) => sum + (sale['total'] as num));
  }

  double _calculateMonthlySales(List<dynamic> sales) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return sales
        .where((sale) => DateTime.parse(sale['timestamp']).isAfter(monthStart))
        .fold(0.0, (sum, sale) => sum + (sale['total'] as num));
  }

  List<Map<String, dynamic>> _getTodaysSales(List<dynamic> sales) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return sales
        .where((sale) =>
            DateTime.parse(sale['timestamp']).isAfter(today) ||
            DateTime.parse(sale['timestamp']).isAtSameMomentAs(today))
        .map((sale) => Map<String, dynamic>.from(sale))
        .toList();
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                          selectedDatePreset = 'Custom';
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D3B4A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            startDate != null
                                ? DateFormat('MMM dd, yyyy').format(startDate!)
                                : 'Start Date',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'to',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                          selectedDatePreset = 'Custom';
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D3B4A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            endDate != null
                                ? DateFormat('MMM dd, yyyy').format(endDate!)
                                : 'End Date',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Today',
                  'Last 7 Days',
                  'This Month',
                  'Custom',
                ].map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(preset),
                      selected: selectedDatePreset == preset,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedDatePreset = preset;
                            final now = DateTime.now();
                            switch (preset) {
                              case 'Today':
                                startDate =
                                    DateTime(now.year, now.month, now.day);
                                endDate = now;
                                break;
                              case 'Last 7 Days':
                                startDate =
                                    now.subtract(const Duration(days: 7));
                                endDate = now;
                                break;
                              case 'This Month':
                                startDate = DateTime(now.year, now.month, 1);
                                endDate = now;
                                break;
                              case 'Custom':
                                // Leave dates as they are
                                break;
                            }
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildDateRangeSelector(),
              _buildFilterChips(),
              Expanded(
                child: _buildSalesContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sales',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => FilterBottomSheet(
          currentFilters: _filters,
          onApplyFilters: (filters) {
            setState(() {
              _filters = filters;
            });
            _applyFilters();
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    List<Widget> chips = [];

    if (_filters['category'] != null) {
      chips.add(_buildFilterChip('Category: ${_filters['category']}'));
    }
    if (_filters['product'] != null) {
      chips.add(_buildFilterChip('Product: ${_filters['product']}'));
    }
    if (_filters['cashier'] != null) {
      chips.add(_buildFilterChip('Cashier: ${_filters['cashier']}'));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: () {
          setState(() {
            if (label.startsWith('Category:')) {
              _filters['category'] = null;
            } else if (label.startsWith('Product:')) {
              _filters['product'] = null;
            } else if (label.startsWith('Cashier:')) {
              _filters['cashier'] = null;
            }
          });
          _applyFilters();
        },
      ),
    );
  }

  void _applyFilters() {
    // Get all sales within the date range
    final salesBox = Hive.box('sales');
    var filteredSales = salesBox.values.where((sale) {
      final saleDate = DateTime.parse(sale['timestamp']);
      return saleDate.isAfter(startDate!) &&
          saleDate.isBefore(endDate!.add(const Duration(days: 1)));
    }).toList();

    // Apply category filter
    if (_filters['category'] != null) {
      filteredSales = filteredSales.where((sale) {
        return sale['items']
            .any((item) => item['category'] == _filters['category']);
      }).toList();
    }

    // Apply product filter
    if (_filters['product'] != null) {
      filteredSales = filteredSales.where((sale) {
        return sale['items'].any((item) => item['name'] == _filters['product']);
      }).toList();
    }

    // Apply cashier filter
    if (_filters['cashier'] != null) {
      filteredSales = filteredSales.where((sale) {
        return sale['cashier'] == _filters['cashier'];
      }).toList();
    }

    // Update the UI based on analysis view
    setState(() {
      // Update your state variables here based on filtered sales
    });
  }

  Widget _buildSalesContent() {
    final analysisView = _filters['analysisView'] ?? 'Transactions';

    switch (analysisView) {
      case 'Transactions':
        return _buildTransactionsList();
      case 'Top Products':
        return _buildTopProductsAnalysis();
      case 'Categories':
        return _buildCategoriesAnalysis();
      case 'Peak Hours':
        return _buildPeakHoursAnalysis();
      default:
        return _buildTransactionsList();
    }
  }

  Widget _buildTransactionsList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('sales').listenable(),
      builder: (context, box, _) {
        var filteredSales = box.values.where((sale) {
          final saleDate = DateTime.parse(sale['timestamp']);
          return saleDate.isAfter(startDate!) &&
              saleDate.isBefore(endDate!.add(const Duration(days: 1)));
        }).toList();

        // Apply filters
        if (_filters['category'] != null) {
          filteredSales = filteredSales.where((sale) {
            return sale['items']
                .any((item) => item['category'] == _filters['category']);
          }).toList();
        }

        if (_filters['product'] != null) {
          filteredSales = filteredSales.where((sale) {
            return sale['items']
                .any((item) => item['name'] == _filters['product']);
          }).toList();
        }

        if (_filters['cashier'] != null) {
          filteredSales = filteredSales.where((sale) {
            return sale['cashier'] == _filters['cashier'];
          }).toList();
        }

        if (filteredSales.isEmpty) {
          return const Center(
            child: Text('No sales found'),
          );
        }

        // Calculate totals
        double totalSales = 0;
        int totalItems = 0;

        for (var sale in filteredSales) {
          totalSales += sale['total'] as double;
          for (var item in sale['items']) {
            totalItems += item['quantity'] as int;
          }
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D3B4A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Sales',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₱${totalSales.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D3B4A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Items Sold',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalItems.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSales.length,
                itemBuilder: (context, index) {
                  final sale = filteredSales[index];
                  return Card(
                    child: ExpansionTile(
                      title: Text(
                        DateFormat('MMM dd, yyyy hh:mm a').format(
                          DateTime.parse(sale['timestamp']),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cashier: ${sale['cashier']}',
                            style: const TextStyle(fontSize: 12),
                          ),
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
                                    'Amount Paid: ₱${sale['amountPaid'].toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    'Change: ₱${(sale['amountPaid'] - sale['total']).toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green),
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
    );
  }

  Widget _buildTopProductsAnalysis() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('sales').listenable(),
      builder: (context, box, _) {
        final sales = box.values.toList();
        if (sales.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        }

        // Calculate product frequencies
        Map<String, int> productFrequency = {};
        for (var sale in sales) {
          for (var item in sale['items']) {
            final productName = item['name'] as String;
            productFrequency[productName] =
                (productFrequency[productName] ?? 0) +
                    (item['quantity'] as int);
          }
        }

        // Sort products by frequency
        var sortedProducts = productFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedProducts.length,
          itemBuilder: (context, index) {
            final product = sortedProducts[index];
            return Card(
              child: ListTile(
                title: Text(product.key),
                trailing: Text(
                  '${product.value} sold',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesAnalysis() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('sales').listenable(),
      builder: (context, box, _) {
        final sales = box.values.toList();
        if (sales.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        }

        // Calculate category totals
        Map<String, double> categoryTotals = {};
        for (var sale in sales) {
          for (var item in sale['items']) {
            final category = item['category'] as String;
            final total = (item['price'] as double) * (item['quantity'] as int);
            categoryTotals[category] =
                (categoryTotals[category] ?? 0.0) + total;
          }
        }

        // Sort categories by total
        var sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedCategories.length,
          itemBuilder: (context, index) {
            final category = sortedCategories[index];
            return Card(
              child: ListTile(
                title: Text(category.key),
                trailing: Text(
                  '₱${category.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPeakHoursAnalysis() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('sales').listenable(),
      builder: (context, box, _) {
        final sales = box.values.toList();
        if (sales.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        }

        // Calculate hourly totals
        Map<int, double> hourlyTotals = {};
        for (var sale in sales) {
          final saleTime = DateTime.parse(sale['timestamp']);
          final hour = saleTime.hour;
          hourlyTotals[hour] =
              (hourlyTotals[hour] ?? 0.0) + (sale['total'] as double);
        }

        // Sort hours by total
        var sortedHours = hourlyTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedHours.length,
          itemBuilder: (context, index) {
            final hourData = sortedHours[index];
            final hour = hourData.key;
            final total = hourData.value;

            // Format hour string (e.g., "9:00 AM - 10:00 AM")
            final hourString = '${hour.toString().padLeft(2, '0')}:00 - '
                '${((hour + 1) % 24).toString().padLeft(2, '0')}:00';

            return Card(
              child: ListTile(
                title: Text(hourString),
                trailing: Text(
                  '₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
