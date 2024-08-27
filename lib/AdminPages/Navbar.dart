import 'package:ielect/AdminPages/Account.dart';
import 'package:ielect/AdminPages/Candidates.dart';
import 'package:ielect/AdminPages/Voters.dart';
import 'package:ielect/AdminPages/elections.dart';
import 'package:flutter/material.dart';

import 'Cities.dart';
import 'HomePage.dart';




class AdminNavbar extends StatefulWidget {
  const AdminNavbar({Key? key}) : super(key: key);

  @override
  AdminNavbarState createState() => AdminNavbarState();
}

class AdminNavbarState extends State<AdminNavbar> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      Homepage(),
      // Cities(),
      Voters(),
      Candidates(),
      // Elections(),
      admin_Account(),
    ];
  }

  //method for dynamic menu items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 10,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueGrey,
        items: const [
          BottomNavigationBarItem(
            
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",),

          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_circle_outlined),
              activeIcon: Icon(Icons.person_pin_circle_rounded),
              label: "Voters"),

          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_outlined),
              activeIcon: Icon(Icons.person_pin_rounded),
              label: "Candidates"),

          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              activeIcon: Icon(Icons.settings_rounded),
              label: "Settings"),    // BottomNavigationBarItem(
          //     icon: Icon(Icons.where_to_vote_outlined),
          //     activeIcon: Icon(Icons.where_to_vote_rounded),
          //     label: "Election"),

          // BottomNavigationBarItem(
          //     icon: Icon(Icons.location_city_outlined),
          //     activeIcon: Icon(Icons.location_city_rounded),
          //     label: "Cities"),
        ],
      ),
    );
  }
}
// BottomNavigationBarItem(
// icon: Icon(Icons.group_add_outlined),
// activeIcon: Icon(Icons.group_add_rounded),
// label: "Roles"),