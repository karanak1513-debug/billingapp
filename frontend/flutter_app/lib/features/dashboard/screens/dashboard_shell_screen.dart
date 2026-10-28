import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../../billing/screens/billing_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../settings/screens/settings_screen.dart';

class DashboardShellScreen extends ConsumerWidget {
  const DashboardShellScreen({super.key});

  static const List<Widget> _screens = [
    BillingScreen(),
    HistoryScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.creamCard,
          border: const Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) {
            ref.read(selectedNavIndexProvider.notifier).state = idx;
          },
          backgroundColor: AppColors.creamCard,
          indicatorColor: AppColors.burgundy,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.point_of_sale_outlined),
              selectedIcon: const Icon(
                Icons.point_of_sale,
                color: Colors.white,
              ),
              label: 'Billing POS',
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long, color: Colors.white),
              label: 'History',
            ),
            NavigationDestination(
              icon: const Icon(Icons.donut_small_outlined),
              selectedIcon: const Icon(Icons.donut_small, color: Colors.white),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: const Icon(Icons.tune_outlined),
              selectedIcon: const Icon(Icons.tune, color: Colors.white),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
