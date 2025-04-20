import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:staff_task_management/mobile/mob_Profile.dart';
import 'package:staff_task_management/mobile/mob_contact_prev.dart';
import 'package:staff_task_management/mobile/mob_task_mgmt.dart';
import 'package:staff_task_management/scanner_page.dart';
import 'package:staff_task_management/web/web_add_task.dart';
import 'package:staff_task_management/web/detailsWeb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _currentIndex = 2;
  final List<Widget> _pages = [
    QrCodeScanner(),
    Web_Add_Task(),
    DetailsWeb(),
    ContactPrev(),
    Task_mgmt()
  ];
  String name = '';
  bool _isLoading = true; // Add loading state

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    try {
      final response = await http.get(
          Uri.parse('https://creativecollege.in/Flutter/Profile.php?id=$userID'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List && jsonData.isNotEmpty) {
          final firstElement = jsonData[0];
          setState(() {
            name = firstElement['name'];
            _isLoading = false; // Data loaded
          });
        } else {
          setState(() {
            name = 'Data not found';
            _isLoading = false; // Data loading failed
          });
        }
      } else {
        setState(() {
          name = 'Failed to load data';
          _isLoading = false; // Data loading failed
        });
      }
    } catch (e) {
      setState(() {
        name = 'Network error';
        _isLoading = false; // Data loading failed
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black app bar
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.person,
                size: 40,
                color: Colors.white, // White icon
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Profile()));
              },
            ),
          ),
        ],
        title: Text(
          _isLoading ? 'Loading...' : 'HI ,$name',
          style: TextStyle(color: Colors.white), // White text
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white,)) // Loading indicator
          : _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.black, // Black bottom navigation bar
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white, // White selected item
          unselectedItemColor: Colors.grey, // Grey unselected item
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_task),
              label: 'Add Task',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Task Details',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_phone),
              label: 'Student Contact',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Task Management',
            ),
          ],
        ),
      ),
    );
  }
}