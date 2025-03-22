import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox('users');
  await Hive.openBox('products');
  await Hive.openBox('sales');
  await Hive.openBox('categories');

  // Initialize default admin user if not exists
  final usersBox = Hive.box('users');
  if (usersBox.isEmpty) {
    await usersBox.put('1', {
      'username': '1',
      'password': '1',
      'role': 'admin',
    });
    // Add default cashier
    await usersBox.put('2', {
      'username': '2',
      'password': '2',
      'role': 'cashier',
    });
  }

  // Initialize default categories if not exists
  final categoriesBox = Hive.box('categories');
  if (categoriesBox.isEmpty) {
    final defaultCategories = [
      {'id': '1', 'name': 'Disposable'},
      {'id': '2', 'name': 'Device'},
      {'id': '3', 'name': 'Pod'},
      {'id': '4', 'name': 'Accessory'},
    ];
    for (var category in defaultCategories) {
      await categoriesBox.add(category);
    }
  }

  // Initialize default products if not exists
  final productsBox = Hive.box('products');
  if (productsBox.isEmpty) {
    await productsBox.add({
      'name': 'Vape1',
      'price': 999.0,
      'category': 'Disposable',
    });
  }

  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashiering System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
