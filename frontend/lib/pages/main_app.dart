import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'server_page.dart';
import 'alerts_page.dart';
import 'profile_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ServerPage(),
    const AlertsPage(),
    const ProfilePage(),
    const DashboardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: "Server",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: "Dashboard"),
        ],
      ),
    );
  }
}
