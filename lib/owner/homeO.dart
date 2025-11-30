import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:project/owner/dashboard.dart';

import 'package:project/owner/panel.dart';
import 'package:project/screens/profile.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // 📦 Store pages in a list
  final List<Widget> _pages = [
    AdminBookingsScreen(),
    AdminDashboardGrid(),
    ProfileScreen(),
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
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 0, 90, 150),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            onTabChange: _onItemTapped,
            gap: 8,
            backgroundColor: const Color.fromARGB(
              255,
              0,
              90,
              150,
            ), // Make the whole bar orange
            activeColor: Colors.white, // Active icon/text is white
            tabBackgroundColor: const Color.fromARGB(
              255,
              0,
              90,
              150,
            ), // Slightly darker orange for selected tab background (optional, can be same as background)
            color: Colors.white70,
            padding: EdgeInsets.all(
              16,
            ), // Inactive icon/text is slightly transparent white
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.book_outlined, text: 'Booking'),
              GButton(icon: Icons.person_2_rounded, text: "Profile"),
            ],
          ),
        ),
      ), // 👈 display selected page
    );
  }
}
