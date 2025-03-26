import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic> currentFilters;

  const FilterBottomSheet({
    super.key,
    required this.onApplyFilters,
    required this.currentFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? selectedCategory;
  late String? selectedProduct;
  late String? selectedCashier;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.currentFilters['category'];
    selectedProduct = widget.currentFilters['product'];
    selectedCashier = widget.currentFilters['cashier'];
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        chipTheme: ChipThemeData(
          selectedColor: const Color(0xFF4D3B4A),
          backgroundColor: const Color(0xFF2D2D2D),
          labelStyle: const TextStyle(color: Colors.white),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection('Category', _buildCategoryFilter()),
                    _buildFilterSection('Product', _buildProductFilter()),
                    _buildFilterSection('Cashier', _buildCashierFilter()),
                  ],
                ),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedCategory = null;
                selectedProduct = null;
                selectedCashier = null;
              });
            },
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('categories').listenable(),
      builder: (context, box, _) {
        final categories = box.values.toList();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All Categories'),
              selected: selectedCategory == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedCategory = null;
                    selectedProduct = null;
                  });
                }
              },
            ),
            ...categories.map((category) {
              final name = category['name'].toString();
              return ChoiceChip(
                label: Text(name),
                selected: selectedCategory == name,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = selected ? name : null;
                    selectedProduct = null;
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildProductFilter() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('products').listenable(),
      builder: (context, box, _) {
        final allProducts = box.values.toList();

        // Filter products if category is selected
        final products = selectedCategory != null
            ? allProducts
                .where((product) =>
                    product['category'].toString() == selectedCategory)
                .toList()
            : allProducts;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All Products'),
              selected: selectedProduct == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedProduct = null;
                  });
                }
              },
            ),
            ...products.map((product) {
              final name = product['name'].toString();
              return ChoiceChip(
                label: Text(name),
                selected: selectedProduct == name,
                onSelected: (selected) {
                  setState(() {
                    selectedProduct = selected ? name : null;
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCashierFilter() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('users').listenable(),
      builder: (context, box, _) {
        final cashiers = box.values.where((user) {
          return user != null && user['role'] == 'cashier';
        }).toList();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All Cashiers'),
              selected: selectedCashier == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedCashier = null;
                  });
                }
              },
            ),
            ...cashiers.map((cashier) {
              final name = cashier['username']?.toString() ?? 'Unknown';
              return ChoiceChip(
                label: Text(name),
                selected: selectedCashier == name,
                onSelected: (selected) {
                  setState(() {
                    selectedCashier = selected ? name : null;
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          widget.onApplyFilters({
            'category': selectedCategory,
            'product': selectedProduct,
            'cashier': selectedCashier,
          });
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4D3B4A),
          minimumSize: const Size(double.infinity, 50),
          splashFactory: NoSplash.splashFactory,
        ),
        child: const Text('Apply Filters'),
      ),
    );
  }
}
