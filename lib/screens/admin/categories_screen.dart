import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('categories').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No categories added yet'),
            );
          }

          return Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final category = box.getAt(index);
                    return Card(
                      margin: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 4 : 8,
                        horizontal: isSmallScreen ? 4 : 16,
                      ),
                      child: ListTile(
                        title: Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showCategoryForm(context, category),
                              iconSize: isSmallScreen ? 20 : 24,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteCategory(context, index),
                              color: Colors.red,
                              iconSize: isSmallScreen ? 20 : 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(context),
        child: Icon(Icons.add, size: isSmallScreen ? 20 : 24),
      ),
    );
  }

  void _showCategoryForm(BuildContext context, [Map? category]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    _nameController.text = category?['name'] ?? '';
    _editingId = category?['id'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          category == null ? 'Add Category' : 'Edit Category',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
        content: SizedBox(
          width: isSmallScreen ? screenWidth * 0.8 : 400,
          child: Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category name';
                }
                return null;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
          TextButton(
            onPressed: _saveCategory,
            child: Text(
              category == null ? 'Add' : 'Save',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final categoriesBox = Hive.box('categories');
      final categoryData = {
        'id': _editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text.trim(),
      };

      if (_editingId != null) {
        final index = categoriesBox.values
            .toList()
            .indexWhere((c) => c['id'] == _editingId);
        if (index != -1) {
          categoriesBox.putAt(index, categoryData);
        }
      } else {
        categoriesBox.add(categoryData);
      }

      Navigator.pop(context);
      _nameController.clear();
      _editingId = null;
    }
  }

  void _deleteCategory(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final categoriesBox = Hive.box('categories');
              categoriesBox.deleteAt(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
