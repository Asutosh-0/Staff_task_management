import 'package:flutter/material.dart';
// import 'package:flutter_application_1/Admin_DashBoard.dart';
// import 'package:flutter_application_1/Staff_List.dart';
// import 'package:flutter_application_1/Total_Present.dart';
// import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_task_management/Admin_DashBoard.dart';
import 'package:staff_task_management/Staff_List.dart';
import 'package:staff_task_management/Total_Present.dart';
import 'package:staff_task_management/main.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    StaffList(),
    Admin_Dashboard(),
    Total_Attendance()
  ];

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('isLoggedInAdmin');
    await prefs.remove('userID');
    await prefs.remove('password');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Changed to black
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.logout,
                size: 40,
                color: Colors.white, // Changed to white
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      title: Text(
                        "Confirm Logout",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to logout",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            clearSharedPreferences();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
        title: Text(
          'Hi.. ,  Admin',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: Container(
          color: Colors.black, // Changed to black
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.work, color: Colors.black,), // Changed to white
                  label: 'Staff Status',
                  backgroundColor: Colors.black),
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_customize, color: Colors.black), // Changed to white
                  label: 'Dashboard',
                  backgroundColor: Colors.black),
              BottomNavigationBarItem(
                  icon: Icon(Icons.co_present_outlined, color: Colors.black), // Changed to white
                  label: 'Attendance',
                  backgroundColor: Colors.black),
            ],
            selectedItemColor: Colors.blue, // Selected item color changed to white
            unselectedItemColor: Colors.black, // Unselected item color changed to grey
          ),
        ),
      ),
    );
  }
}