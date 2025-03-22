import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final double total;
  final Function(double amountPaid, String customerName) onPaymentComplete;

  const PaymentDialog({
    super.key,
    required this.total,
    required this.onPaymentComplete,
  });

  @override
  PaymentDialogState createState() => PaymentDialogState();
}

class PaymentDialogState extends State<PaymentDialog> {
  final _amountController = TextEditingController();
  final _customerNameController = TextEditingController();
  double _change = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateChange);
  }

  void _calculateChange() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _change = amount - widget.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount Paid',
              border: OutlineInputBorder(),
              prefixText: '₱',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:'),
              Text('₱${widget.total.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Change:'),
              Text(
                '₱${_change.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _change >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _change >= 0 && _customerNameController.text.isNotEmpty
              ? _processPayment
              : null,
          child: const Text('Complete'),
        ),
      ],
    );
  }

  void _processPayment() {
    final amountPaid = double.parse(_amountController.text);
    widget.onPaymentComplete(amountPaid, _customerNameController.text.trim());
  }

  String get customerName => _customerNameController.text.trim();

  @override
  void dispose() {
    _amountController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }
}
