import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import 'login_screen.dart';
import 'admin/products_screen.dart';
import 'admin/users_screen.dart';
import 'admin/sales_report_screen.dart';
import 'cashier/new_sale_screen.dart';
import 'cashier/today_sales_screen.dart';
import 'admin/categories_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final String role;

  const HomeScreen({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUPERMAN VAPESHOP'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome, $username (${role.toUpperCase()})',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (role == 'cashier')
                _buildCashierDashboard(context)
              else
                _buildAdminDashboard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDashboard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 48) / (screenWidth > 600 ? 4 : 2);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: [
            SizedBox(
              width: buttonWidth,
              child: MenuButton(
                title: 'Products',
                icon: Icons.inventory,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                ),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: MenuButton(
                title: 'Categories',
                icon: Icons.category,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: MenuButton(
                title: 'Users',
                icon: Icons.people,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersScreen()),
                ),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: MenuButton(
                title: 'Sales Report',
                icon: Icons.bar_chart,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashierDashboard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 48) / (screenWidth > 600 ? 2 : 1);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: [
            SizedBox(
              width: buttonWidth,
              child: MenuButton(
                title: 'New Sale',
                icon: Icons.point_of_sale,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewSaleScreen(cashierName: username),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: MenuButton(
                title: 'Today\'s Sales',
                icon: Icons.receipt_long,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TodaySalesScreen(cashierName: username),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
