import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../widgets/dialogs/payment_dialog.dart';

class NewSaleScreen extends StatefulWidget {
  final String cashierName;

  const NewSaleScreen({
    super.key,
    required this.cashierName,
  });

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _customerNameController = TextEditingController();
  final List<Map<String, dynamic>> cart = [];
  double total = 0;

  void _addToCart(Map<String, dynamic>? product) {
    if (product == null) return;

    try {
      final existingIndex =
          cart.indexWhere((item) => item['name'] == product['name']);

      setState(() {
        if (existingIndex != -1) {
          cart[existingIndex]['quantity']++;
        } else {
          cart.add({
            'name': product['name'] as String,
            'price': (product['price'] as num).toDouble(),
            'quantity': 1,
          });
        }
        _updateTotal();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error adding product to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      if (cart[index]['quantity'] > 1) {
        cart[index]['quantity']--;
      } else {
        cart.removeAt(index);
      }
      _updateTotal();
    });
  }

  void _updateTotal() {
    total =
        cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Sale',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: isSmallScreen
                    ? Column(
                        children: [
                          // Products List (1/2 of space)
                          Expanded(
                            flex: 1,
                            child: _buildProductsList(),
                          ),
                          // Cart (1/2 of space)
                          Expanded(
                            flex: 1,
                            child: _buildCart(),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Products List (1/2 of width)
                          Expanded(
                            flex: 1,
                            child: _buildProductsList(),
                          ),
                          // Cart (1/2 of width)
                          Expanded(
                            flex: 1,
                            child: _buildCart(),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('products').listenable(),
              builder: (context, box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No products available'));
                }
                final products = box.values.toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    if (product == null) return const SizedBox.shrink();

                    double price = 0.0;
                    try {
                      price = (product['price'] as num).toDouble();
                    } catch (e) {
                      price = 0.0;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                            product['name']?.toString() ?? 'Unknown Product'),
                        subtitle: Text(
                          '₱${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onTap: () => _addToCart({
                          'name':
                              product['name']?.toString() ?? 'Unknown Product',
                          'price': price,
                        }),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCart() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'Total: ₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      '₱${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _removeFromCart(index),
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'COMPLETE SALE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PaymentDialog(
        total: total,
        onPaymentComplete: (double amountPaid, String paymentMethod) {
          // Close payment dialog first
          Navigator.of(context).pop();

          // Then process the sale
          final salesBox = Hive.box('sales');
          final saleItems = List<Map<String, dynamic>>.from(cart);
          final saleTotal = total;
          final timestamp = DateTime.now();
          final customerName = paymentMethod;

          // Save to Hive
          salesBox.add({
            'timestamp': timestamp.toIso8601String(),
            'cashier': widget.cashierName,
            'customerName': customerName,
            'items': saleItems,
            'total': saleTotal,
            'amountPaid': amountPaid,
            'change': amountPaid - saleTotal,
          });

          // Show receipt dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: const Center(
                child: Text(
                  'SUPERMAN VAPESHOP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(timestamp)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Time: ${DateFormat('HH:mm').format(timestamp)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Cashier: ${widget.cashierName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Customer: $customerName',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 24),
                    ...saleItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['quantity']} × ₱${item['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₱${saleTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount Paid:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '₱${amountPaid.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '₱${(amountPaid - saleTotal).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Clear the cart
                    setState(() {
                      cart.clear();
                      total = 0;
                    });

                    // Close receipt dialog
                    Navigator.of(context).pop();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sale completed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'CLOSE',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }
}
