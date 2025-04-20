import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_task_management/Report_upload.dart';
import 'package:staff_task_management/attendance/attendance.dart';
import 'package:staff_task_management/feedback/stafffeedback.dart';
import 'package:staff_task_management/mobile/Staff_Attendance.dart';
import 'package:staff_task_management/mobile/detailsMobile.dart';
import 'package:staff_task_management/mobile/mob_add_task.dart';
import 'package:staff_task_management/mobile/mob_contact_prev.dart';
import 'package:staff_task_management/mobile/mob_task_mgmt.dart';
import 'package:staff_task_management/staff_leave.dart';
import 'package:staff_task_management/student_attendance.dart';
import 'package:url_launcher/url_launcher.dart';
import 'mobile/mob_Profile.dart';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:async';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _color1 = const Color(0xFFC21E56);
  XFile? _pickedImage;
  late String pickedImagePath;
  Map<String, dynamic>? data;
  bool isLoading = true;
  String error = '';

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
        _pickedImage = XFile(savedImagePath);
      }
    });
  }

  Future<void> fetchData(String id) async {
    final url =
        'https://creativecollege.in/Flutter/Work/singledata_redflag.php?id=$id';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the JSON
        setState(() {
          data = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception
        setState(() {
          error = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle any errors that occur
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
    fetchData("Bhabani@CTC");
  }
  Widget _buildCard(String imagePath, String title, VoidCallback onTap, int index) {
    return FadeInUp(
      duration: Duration(milliseconds: 500 + (index * 100)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    imagePath,
                    height: 44,
                    width: 44,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCD8CD),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0A0707),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              // title: const Text(
              //   'HOME',
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black,
              //     fontSize: 26,
              //   ),
              // ),
             flexibleSpace: FlexibleSpaceBar(
  background: BannerDisplay(), // Use our static banner widget
),
              actions: <Widget>[
                Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    children: <Widget>[
                      Row(
                        children: [
                          Card(
                            color: const Color(0xFF2E2045),
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${data != null && data!.containsKey('COUNT') ? data!['COUNT'] : '0'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.flag,
                                    color: Colors.redAccent,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const Profile(),
                      //       ),
                      //     );
                      //   },
                      //   child: CircleAvatar(
                      //     radius: 20,
                      //     backgroundColor: const Color(0xFF592D52),
                      //     backgroundImage: _pickedImage == null
                      //         ? const AssetImage('assets/images/technocart.png')
                      //         : FileImage(File(_pickedImage!.path))
                      //     as ImageProvider<Object>?,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildSmallScreenView(context);
            } else {
              return _buildLargeScreenView(context);
            }
          },
        ),
      ),
    );
  }
  final String url = "https://creativecollege.in/MIS/MIS/Note%20and%20assignment%20project%201/index.php";

  void _launchURL() async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildSmallScreenView(BuildContext context) {
    return Stack( // Wrap GridView in a Stack
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                // ... (Your switch case code for building cards)
                switch (index) {
                  case 0:
                    return _buildCard('assets/icons/contact.png', 'Student Contact Record', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPrev()));
                    }, index);
                  case 1:
                    return _buildCard('assets/icons/work.png', 'Work Details', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsMobile()));
                    }, index);
                  case 2:
                    return _buildCard('assets/icons/task.png', 'Task Management', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Task_mgmt()));
                    }, index);
                  case 3:
                    return _buildCard('assets/icons/self attendance.png', 'Self Attendance', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Staff_Attendanance()));
                    }, index);
                  case 4:
                    return _buildCard('assets/icons/report.png', 'Report', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Report_upload()));
                    }, index);
                  case 5:
                    return _buildCard('assets/icons/add task.png', 'Add Task', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Mob_Add_Task()));
                    }, index);
                  case 6:
                    return _buildCard('assets/icons/apply for leave.png', 'Apply Leave', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Leave_Page()));
                    }, index);
                  case 7:
                    return _buildCard('assets/icons/student attendance.png', 'Student Attendance', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Attendance()));
                    }, index);
                  case 8:
                    return _buildCard('assets/icons/feedback.png', 'Feedback', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherFeedbackpage()));
                    }, index);
                  case 9:
                    return _buildCard('assets/icons/mis.png', 'Notes and Assignment', () {
                      _launchURL();
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen()));
                    }, index);
                  default:
                    return Container();
                }
              },
            ),
          ),
        ),
        Align( // Align the animated text at the bottom center
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AnimatedSwitcher( // Use AnimatedSwitcher for fade out
              duration: const Duration(milliseconds: 1500),
              child: _buildAnimatedText(), // Build the animated text widget
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedText() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 1500)), // Delay for 1.5 seconds
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const SizedBox.shrink(); // Hide the text after the delay
        } else {
          return DefaultTextStyle(
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText('Designed by Ananta k.swain'),
              ],
              isRepeatingAnimation: false,
              totalRepeatCount: 1,
            ),
          );
        }
      },
    );
  }

  

  Widget _buildLargeScreenView(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(5.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder( // Changed to GridView.builder
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildCard('assets/icons/contact.png', 'Student Contact Record', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPrev()));
                  }, index);
                case 1:
                  return _buildCard('assets/icons/work.png', 'Work Details', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsMobile()));
                  }, index);
                case 2:
                  return _buildCard('assets/icons/task.png', 'Task Management', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => Task_mgmt()));
                  }, index);
                case 3:
                  return _buildCard('assets/icons/self attendance.png', 'Self Attendance', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => Staff_Attendanance()));
                  }, index);
                case 4:
                  return _buildCard('assets/icons/report.png', 'Report', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => Report_upload()));
                  }, index);
                case 5:
                  return _buildCard('assets/icons/add task.png', 'Add Task', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => Mob_Add_Task()));
                  }, index);
                case 6:
                  return _buildCard('assets/icons/apply for leave.png', 'Apply Leave', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => Leave_Page()));
                  }, index);
                case 7:
                  return _buildCard('assets/icons/student attendance.png', 'Student Attendance', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => StudentAttendance()));
                  }, index);
                case 8:
                  return _buildCard('assets/icons/feedback.png', 'Feedback', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherFeedbackpage()));
                  }, index);
                case 9:
                  return _buildCard('assets/icons/mis.png', 'Notes & Assignment', () {
                    _launchURL();
                    //  Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen()));
                  }, index);
                default:
                  return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
class BannerDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get current day (0=Sunday, 1=Monday, ..., 6=Saturday)
    final dayOfWeek = DateTime.now().weekday;
    
    // Map days to different banners
    final bannerImages = [
      'assets/images/banner1.png', // Sunday
      'assets/images/banner2.jpg', // Monday
      'assets/images/banner3.jpg', // Tuesday
      'assets/images/banner4.png', // Wednesday
      'assets/images/banner5.png', // Thursday
      'assets/images/banner6.png', // Friday
      'assets/images/banner7.jpg', // Saturday
    ];
    
    // Ensure we don't go out of bounds
    final bannerIndex = dayOfWeek % bannerImages.length;
    
    return Image.asset(
      bannerImages[bannerIndex],
      fit: BoxFit.cover,
    );
  }
}