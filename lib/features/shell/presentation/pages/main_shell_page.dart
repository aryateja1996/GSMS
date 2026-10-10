import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/widgets/sync_status_banner.dart';
import 'package:gsma/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:gsma/features/inventory/presentation/pages/inventory_page.dart';
import 'package:gsma/features/khata/presentation/pages/khata_page.dart';
import 'package:gsma/features/more/presentation/pages/more_page.dart';
import 'package:gsma/features/pos/presentation/pages/pos_page.dart';
import 'package:gsma/features/reports/presentation/pages/reports_page.dart';
import 'package:gsma/features/shell/presentation/controllers/main_shell_controller.dart';

class MainShellPage extends GetView<MainShellController> {
  const MainShellPage({super.key});

  static const _tabs = <Widget>[
    DashboardPage(),
    PosPage(),
    InventoryPage(),
    KhataPage(),
    ReportsPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Obx(() {
      final index = controller.tabIndex.value;
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SyncStatusBanner(),
          Expanded(child: _tabs[index]),
        ],
      );

      if (wide) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: index,
                onDestinationSelected: controller.selectTab,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.point_of_sale_outlined),
                    selectedIcon: Icon(Icons.point_of_sale),
                    label: Text('POS'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('Stock'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: Text('Khata'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: Text('Reports'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.more_horiz),
                    selectedIcon: Icon(Icons.more_horiz),
                    label: Text('More'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          ),
        );
      }

      return Scaffold(
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale),
              label: 'POS',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Stock',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Khata',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      );
    });
  }
}
