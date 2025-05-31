// lib/widgets/app_drawer.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/monitoring_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/maintenance_screen.dart';
import '../screens/configuration_screen.dart';
import '../screens/about_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : Colors.black87),
      title: Text(
        text,
        style: TextStyle(color: selected ? Colors.blue : Colors.black87),
      ),
      selected: selected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[700], // Darker blue for header
            ),
            child: const Text(
              'Estação Separadora',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _createDrawerItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            selected: currentRoute == DashboardScreen.routeName,
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (currentRoute != DashboardScreen.routeName) {
                Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
              }
            },
          ),
          _createDrawerItem(
            icon: Icons.monitor_heart,
            text: 'Monitoramento',
            selected: currentRoute == MonitoringScreen.routeName,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != MonitoringScreen.routeName) {
                Navigator.pushReplacementNamed(context, MonitoringScreen.routeName);
              }
            },
          ),
          _createDrawerItem(
            icon: Icons.assessment,
            text: 'Relatórios',
            selected: currentRoute == ReportsScreen.routeName,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != ReportsScreen.routeName) {
                Navigator.pushReplacementNamed(context, ReportsScreen.routeName);
              }
            },
          ),
          _createDrawerItem(
            icon: Icons.build,
            text: 'Manutenção',
            selected: currentRoute == MaintenanceScreen.routeName,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != MaintenanceScreen.routeName) {
                Navigator.pushReplacementNamed(context, MaintenanceScreen.routeName);
              }
            },
          ),
          _createDrawerItem(
            icon: Icons.settings,
            text: 'Configuração',
            selected: currentRoute == ConfigurationScreen.routeName,
            onTap: () {
              Navigator.pop(context);
               if (currentRoute != ConfigurationScreen.routeName) {
                Navigator.pushReplacementNamed(context, ConfigurationScreen.routeName);
               }
            },
          ),
          const Divider(),
          _createDrawerItem(
            icon: Icons.info_outline,
            text: 'Sobre',
            selected: currentRoute == AboutScreen.routeName,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != AboutScreen.routeName) {
                Navigator.pushReplacementNamed(context, AboutScreen.routeName);
              }
            },
          ),
        ],
      ),
    );
  }
}