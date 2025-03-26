import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox('users');
  await Hive.openBox('products');
  await Hive.openBox('sales');
  await Hive.openBox('categories');

  final usersBox = Hive.box('users');
  if (usersBox.isEmpty) {
    await usersBox.put('1', {
      'username': '1',
      'password': '1',
      'role': 'admin',
    });
    await usersBox.put('2', {
      'username': '2',
      'password': '2',
      'role': 'cashier',
    });
  }

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
      title: 'SUPERMAN VAPESHOP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red[400],
        scaffoldBackgroundColor: const Color(0xFF2D1F2A),
        cardColor: const Color(0xFF3D2B3A),
        colorScheme: ColorScheme.dark(
          primary: Colors.red[400]!,
          secondary: Colors.purple[400]!,
          surface: const Color(0xFF3D2B3A),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.grey[300],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 4,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF3D2B3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF4D3B4A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[400]!),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xFF2D1F2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
