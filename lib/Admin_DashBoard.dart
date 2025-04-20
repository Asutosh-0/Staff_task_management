import 'package:flutter/material.dart';
import 'package:staff_task_management/Add_staff.dart';
import 'package:staff_task_management/Admin_Contact.dart';
import 'package:staff_task_management/Admin_DateWise_Work_View.dart';
import 'package:staff_task_management/Admin_leave_Mgmt.dart';
import 'package:staff_task_management/admin_add_work.dart';
import 'package:staff_task_management/attendance/attendance.dart';
import 'package:staff_task_management/del_staff.dart';
import 'package:staff_task_management/feedback/feedbackpage.dart';
import 'package:staff_task_management/work/showredflag.dart';
import 'package:staff_task_management/work/workdelay.dart';

class Admin_Dashboard extends StatefulWidget {
  const Admin_Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Admin_Dashboard> {
  late String pickedImagePath;

  Widget _buildCard(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildSmallScreenView();
          } else {
            return _buildLargeScreenView();
          }
        },
      ),
    );
  }

  Widget _buildSmallScreenView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: _buildDashboardCards(context),
      ),
    );
  }

  Widget _buildLargeScreenView() {
    return Center(
      child: SizedBox(
        width: 800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: _buildDashboardCards(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDashboardCards(BuildContext context) {
    return [
      _buildCard(Icons.work_history, 'Date Wise Work', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDateWiseWork(),
          ),
        );
      }),
      _buildCard(Icons.delete_forever, 'Delete Staff', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffDelete(),
          ),
        );
      }),
      _buildCard(Icons.leave_bags_at_home_outlined, 'Staff Leave', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Admin_Leave_Page(),
          ),
        );
      }),
      _buildCard(Icons.present_to_all, 'Student Contact', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Admin_ContactPrev(),
          ),
        );
      }),
      _buildCard(Icons.add, 'Add Staff', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffAdd(),
          ),
        );
      }),
      _buildCard(Icons.present_to_all, 'Student Attendnance', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Attendance(),
          ),
        );
      }),
      _buildCard(Icons.assignment_add, 'Assign Work', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Admin_ADD_WORK(),
          ),
        );
      }),
      _buildCard(Icons.assignment_add, 'Assign Flag', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Workdelay(),
          ),
        );
      }),
      _buildCard(Icons.assignment_add, 'Red Flag Faculty', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RedFlagPage(),
          ),
        );
      }),
      _buildCard(Icons.assignment_add, 'Feedback', () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Feedbackpage(),
          ),
        );
      }),
    ];
  }
}