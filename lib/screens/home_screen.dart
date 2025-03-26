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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_getTimeOfDay()},',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          '$username!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 32,
                              ),
                        ),
                        Text(
                          role.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 28),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: role == 'cashier'
                      ? _buildCashierDashboard(context)
                      : _buildAdminDashboard(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
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
                title: 'Sales',
                icon: Icons.assessment,
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
