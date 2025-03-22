import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/dialogs/payment_dialog.dart';

class NewSaleScreen extends StatefulWidget {
  final String cashierName;

  const NewSaleScreen({
    super.key,
    required this.cashierName,
  });

  @override
  NewSaleScreenState createState() => NewSaleScreenState();
}

class NewSaleScreenState extends State<NewSaleScreen> {
  final List<Map<String, dynamic>> cart = [];
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  double total = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isSmallScreen
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search Products',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box('categories').listenable(),
                          builder: (context, box, _) {
                            final categories = [
                              'All',
                              ...box.values.map((c) => c['name'] as String)
                            ];
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  items: categories.map((String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(
                                        category,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCategory = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProductsGrid(),
                        _buildCartPanel(),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  labelText: 'Search Products',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 200,
                              child: ValueListenableBuilder(
                                valueListenable:
                                    Hive.box('categories').listenable(),
                                builder: (context, box, _) {
                                  final categories = [
                                    'All',
                                    ...box.values
                                        .map((c) => c['name'] as String)
                                  ];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCategory,
                                        isExpanded: true,
                                        items:
                                            categories.map((String category) {
                                          return DropdownMenuItem<String>(
                                            value: category,
                                            child: Text(
                                              category,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedCategory = newValue;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildProductsGrid(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: _buildCartPanel(),
                ),
              ],
            ),
    );
  }

  Widget _buildProductsGrid() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('products').listenable(),
      builder: (context, box, _) {
        final products = box.values.where((product) {
          final matchesSearch = product['name']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
          final matchesCategory = _selectedCategory == 'All' ||
              product['category'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        return LayoutBuilder(builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;

          return GridView.builder(
            shrinkWrap: MediaQuery.of(context).size.width < 800,
            physics: MediaQuery.of(context).size.width < 800
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: InkWell(
                  onTap: () => _addToCart(product, index),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              product['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        Text(
                          product['category'] ?? 'Uncategorized',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${product['price'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  void _addToCart(Map product, int index) {
    final existingIndex =
        cart.indexWhere((item) => item['name'] == product['name']);

    if (existingIndex != -1) {
      setState(() {
        cart[existingIndex]['quantity']++;
        _updateTotal();
      });
    } else {
      setState(() {
        cart.add({
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
          'productIndex': index,
        });
        _updateTotal();
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      cart.removeAt(index);
      _updateTotal();
    });
  }

  void _clearCart() {
    setState(() {
      cart.clear();
      total = 0;
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      cart[index]['quantity'] = quantity;
      _updateTotal();
    });
  }

  void _updateTotal() {
    total = cart.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  void _processPayment() {
    if (cart.isEmpty) {
      _showMessage('Cart is empty');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        total: total,
        onPaymentComplete: (amountPaid, customerName) {
          final salesBox = Hive.box('sales');
          final saleItems = List<Map<String, dynamic>>.from(cart);
          final saleTotal = total;
          final timestamp = DateTime.now();

          salesBox.add({
            'timestamp': timestamp.toIso8601String(),
            'cashier': widget.cashierName,
            'customerName': customerName,
            'items': saleItems
                .map((item) => {
                      'name': item['name'],
                      'price': item['price'],
                      'quantity': item['quantity'],
                    })
                .toList(),
            'total': saleTotal,
            'amountPaid': amountPaid,
          });

          setState(() {
            cart.clear();
            total = 0;
          });

          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('SUPERMAN VAPESHOP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${timestamp.toString().split(' ')[0]}'),
                  Text(
                      'Time: ${timestamp.toString().split(' ')[1].substring(0, 5)}'),
                  const Divider(),
                  Text('Cashier: ${widget.cashierName}'),
                  Text('Customer: $customerName'),
                  const Divider(),
                  ...saleItems.map((item) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name']),
                          Text(
                              '${item['quantity']} × ₱${item['price'].toStringAsFixed(2)}'),
                          Text(
                              '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                        ],
                      )),
                  const Divider(),
                  Text('TOTAL: ₱${saleTotal.toStringAsFixed(2)}'),
                  Text('Amount Paid: ₱${amountPaid.toStringAsFixed(2)}'),
                  Text(
                      'Change: ₱${(amountPaid - saleTotal).toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Thank you for your purchase!',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showMessage('Sale completed successfully');
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildCartPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cart.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _clearCart,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
              ],
            ),
          ),
          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Cart is empty'),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return ListTile(
                    title: Text(
                      item['name'],
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '₱${item['price'].toStringAsFixed(2)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () {
                              if (item['quantity'] > 1) {
                                _updateQuantity(index, item['quantity'] - 1);
                              } else {
                                _removeFromCart(index);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${item['quantity']}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () => _updateQuantity(
                              index,
                              item['quantity'] + 1,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₱${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cart.isEmpty ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'Process Payment',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
