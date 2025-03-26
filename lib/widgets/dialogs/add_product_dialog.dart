import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D1F2A), // Darker background for dialog
      title: const Text('Add Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4D3B4A), // Lighter grey for input fields
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.inventory),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4D3B4A), // Lighter grey for input fields
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.attach_money),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4D3B4A), // Lighter grey for input fields
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                prefixIcon: Icon(Icons.numbers),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4D3B4A), // Lighter grey for input fields
              borderRadius: BorderRadius.circular(12),
            ),
            child: ValueListenableBuilder(
              valueListenable: Hive.box('categories').listenable(),
              builder: (context, box, _) {
                final categories = box.values.toList();
                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category (Optional)',
                    prefixIcon: Icon(Icons.category),
                    border: InputBorder.none,
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'] as String,
                      child: Text(category['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _priceController.text.isNotEmpty &&
                _quantityController.text.isNotEmpty) {
              final productsBox = Hive.box('products');
              productsBox.add({
                'name': _nameController.text.trim(),
                'price': double.tryParse(_priceController.text) ?? 0.0,
                'quantity': int.tryParse(_quantityController.text) ?? 0,
                'category': _selectedCategory,
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
