import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductFormDialog extends StatefulWidget {
  final int? index;
  final Map? product;

  const ProductFormDialog({
    super.key,
    this.index,
    this.product,
  });

  @override
  ProductFormDialogState createState() => ProductFormDialogState();
}

class ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString();
      _selectedCategory = widget.product!['category'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final dialogWidth = isSmallScreen ? screenWidth * 0.9 : 500.0;

    return Dialog(
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.product == null ? 'Add Product' : 'Edit Product',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '₱',
                    ),
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  ValueListenableBuilder(
                    valueListenable: Hive.box('categories').listenable(),
                    builder: (context, box, _) {
                      final categories =
                          box.values.map((c) => c['name'] as String).toList();
                      _selectedCategory ??=
                          categories.isNotEmpty ? categories.first : null;

                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style:
                                  TextStyle(fontSize: isSmallScreen ? 14 : 16),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 16),
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: Text(
                    widget.product == null ? 'Add' : 'Save',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final productsBox = Hive.box('products');
      final productData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
      };

      if (widget.index != null) {
        productsBox.putAt(widget.index!, productData);
      } else {
        productsBox.add(productData);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
