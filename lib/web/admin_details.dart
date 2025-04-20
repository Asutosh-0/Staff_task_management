import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:staff_task_management/mobile/mob_Profile.dart';
import 'package:staff_task_management/mobile/mob_add_task.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Details_admin_web extends StatefulWidget {
  final String name;

  Details_admin_web({required this.name});
  @override
  _Details_admin_web createState() => _Details_admin_web();
}

class _Details_admin_web extends State<Details_admin_web> {
  List<Task> tasks = [];
  late List<Task> originalTasks = [];
  TaskStatus filter = TaskStatus.all;
  DateTime selectedDate = DateTime.now();
  DateTime lastWeek = DateTime.now().subtract(const Duration(days: 7));
  DateTime? selectedMonth;
  int selectedFilterIndex = 0;
  XFile? _pickedImage;
  late String pickedImagePath;
  String name = '';

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
        _pickedImage = XFile(savedImagePath);
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    name = widget.name;
    initializeData();
    loadImagePath();
    fetchData();
  }

  String designation = '';

  Future<void> initializeData() async {
    final response = await http.get(
        Uri.parse('https://creativecollege.in/Flutter/Admin_staff_details.php?name=$name'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData is List && jsonData.isNotEmpty) {
        final firstElement = jsonData[0];
        setState(() {
          name = firstElement['name'];
        });
      } else {
        setState(() {
          name = 'Data not found';
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
    await fetchData();
    filterTasksToday();
  }

  TaskStatus taskStatusFromString(String status) {
    switch (status) {
      case 'Started':
        return TaskStatus.active;
      case 'Completed':
        return TaskStatus.completed;
      case 'Not Started':
        return TaskStatus.pending;
      default:
        return TaskStatus.all;
    }
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://creativecollege.in/Flutter/Admin_staff_details.php?name=$name'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        tasks = responseData.map((taskData) {
          return Task(
              taskData['TITLE'],
              taskStatusFromString(taskData['STATUS']),
              taskData['ADDDATE'],
              taskData['STARTDATE'],
              taskData['ENDDATE']);
        }).toList();
        originalTasks = List.from(tasks);
      });
    } else {
      throw Exception('Error while fetching data');
    }
  }

  void setFilter(TaskStatus newFilter) {
    setState(() {
      filter = newFilter;
      if (filter == TaskStatus.all) {
        tasks = List.from(originalTasks);
      }
    });
  }

  void filterTasksByDate(DateTime date) {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      selectedDate = date;
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.isAtSameMomentAs(date);
      }).toList();
    });
  }

  void filterTasksLastWeek() {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      lastWeek = DateTime.now().subtract(const Duration(days: 7));
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.isAfter(lastWeek) ||
            taskDate.isAtSameMomentAs(lastWeek);
      }).toList();
    });
  }

  void filterTasksToday() {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      selectedDate = DateTime.now();
      tasks = originalTasks.where((task) {
        final taskDate = DateTime.parse(task.date).toLocal();
        final todayStart = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, 0, 0, 0)
            .toLocal();
        final todayEnd = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, 23, 59, 59)
            .toLocal();
        return taskDate.isAtSameMomentAs(todayStart) ||
            (taskDate.isAfter(todayStart) && taskDate.isBefore(todayEnd));
      }).toList();
    });
  }

  void filterTasksByYear(int year) {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.year == year;
      }).toList();
    });
  }

  void filterTasksByMonth(DateTime? month) {
    if (month == null) {
      return;
    }

    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      selectedMonth = month;
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.month == month.month && taskDate.year == month.year;
      }).toList();
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        filterTasksByDate(selectedDate);
      });
    }
  }

  void _selectMonth(BuildContext context) {
    DateTime now = DateTime.now();
    filterTasksByMonth(DateTime(now.year, now.month));
  }

  void _selectYear(BuildContext context) {
    int currentYear = DateTime.now().year;
    filterTasksByYear(currentYear);
  }

  void _navigateToAddTaskScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Mob_Add_Task()),
    );
  }

  Widget buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: FadeInLeftBig(
          duration: const Duration(milliseconds: 1500),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildFilterOption(" Today ", 0, () => filterTasksToday()),
              buildFilterOption(" This Week ", 1, () => filterTasksLastWeek()),
              buildFilterOption(" This Month ", 2, () {
                _selectMonth(context);
              }),
              buildFilterOption(" This Year ", 3, () {
                _selectYear(context);
              }),
              buildFilterOption(" All ", 4, () => setFilter(TaskStatus.all)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterOption(String label, int index, VoidCallback onPressed) {
    final isSelected = selectedFilterIndex == index;
    final bgColor = isSelected ? Colors.black : Colors.grey[300]; // Black for selected, light grey for others
    final textColor = isSelected ? Colors.white : Colors.black; // White for selected, black for others

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: Colors.grey[400]!), // Slightly darker grey border
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilterIndex = index;
          });
          onPressed();
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    String N = name;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white, // Set background to white
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 1500),
              child: ClipPath(
                clipper: AppBarClipper(),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Colors.black, // AppBar background to black
                  ),
                  child: Row(
                    children: [
                      const Column(
                        children: [
                          SizedBox(height: 30),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 45),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Profile(),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: _pickedImage == null
                                          ? const AssetImage(
                                          'assets/images/technocart.png')
                                          : FileImage(File(_pickedImage!.path))
                                      as ImageProvider<Object>?,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Hi!",
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: Colors.white, // Text color to white
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white, // Text color to white
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40, left: 16),
                            child: Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white), // Icon color to white
                                iconSize: 35,
                                onPressed: () {
                                  Scaffold.of(context).openEndDrawer();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            buildFilterOptions(),
            const SizedBox(
              height: 10,
            ),
            if (tasks.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    Icon(
                      Icons.add_task_rounded,
                      size: 40,
                      color: Colors.black, // Icon color to black
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "There is nothing scheduled",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Text color to black
                      ),
                    ),
                    Text(
                      "Try adding new activities",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Text color to black
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final task = tasks.reversed.toList()[index];

                    if (filter != TaskStatus.all && task.status != filter) {
                      return Container();
                    }

                    String dateToShow = '';

                    if (task.status == TaskStatus.completed) {
                      dateToShow = task.endDate;
                    } else if (task.status == TaskStatus.active) {
                      dateToShow = task.startDate;
                    } else if (task.status == TaskStatus.pending) {
                      dateToShow = task.date;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: FadeInRightBig(
                        duration: const Duration(milliseconds: 420),
                        delay: Duration(milliseconds: index * 22),
                        child: Card(
                          color: Colors.white, // Card background to white
                          child: SizedBox(
                            height: 70,
                            child: Center(
                              child: ListTile(
                                leading: TaskStatusIcon(task.status),
                                title: Text(task.name, style: TextStyle(color: Colors.black)), // Text color to black
                                trailing: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text("start : " + task.startDate, style: TextStyle(color: Colors.black)), // Text color to black
                                    Text("complete : " + task.endDate, style: TextStyle(color: Colors.black)), // Text color to black
                                  ],
                                ),
                              ),
                            ),
                          ),
                          elevation: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white, // Drawer background to white
        width: 300,
        child: ListView(
          children: [
            ListTile(
              title: const Text("All", style: TextStyle(color: Colors.black)), // Text color to black
              selected: filter == TaskStatus.all,
              onTap: () {
                setFilter(TaskStatus.all);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Active", style: TextStyle(color: Colors.black)), // Text color to black
              selected: filter == TaskStatus.active,
              onTap: () {
                setFilter(TaskStatus.active);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Pending", style: TextStyle(color: Colors.black)), // Text color to black
              selected: filter == TaskStatus.pending,
              onTap: () {
                setFilter(TaskStatus.pending);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Completed", style: TextStyle(color: Colors.black)), // Text color to black
              selected: filter == TaskStatus.completed,
              onTap: () {
                setFilter(TaskStatus.completed);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarClipper extends CustomClipper<Path> {
  final double controlPointPercentage;

  AppBarClipper({this.controlPointPercentage = 0.5});

  @override
  Path getClip(Size size) {
    var path = Path();

    final p0 = size.height * 0.75;
    path.lineTo(0, p0);

    final controlPoint =
    Offset(size.width * controlPointPercentage, size.height);
    final endPoint = Offset(
        size.width, size.width < 600 ? size.height / 1.5 : size.height / 2);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) =>
      oldClipper != this;
}

enum TaskStatus { active, completed, pending, all }

class Task {
  final String name;
  final TaskStatus status;
  final String date;
  final String startDate;
  final String endDate;

  Task(this.name, this.status, this.date, this.startDate, this.endDate);
}

class TaskStatusIcon extends StatelessWidget {
  final TaskStatus status;

  TaskStatusIcon(this.status);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;
    switch (status) {
      case TaskStatus.active:
        iconData = Icons.circle;
        color = Colors.black; // Active: Black circle
        break;
      case TaskStatus.completed:
        iconData = Icons.check_circle;
        color = Colors.black; // Completed: Black check circle
        break;
      case TaskStatus.pending:
        iconData = Icons.circle;
        color = Colors.grey[700]!; // Pending: Dark grey circle
        break;
      default:
        iconData = Icons.circle;
        color = Colors.grey; // Default: Grey circle
    }
    return Icon(iconData, color: color);
  }
}

class TaskCount extends StatelessWidget {
  final TaskStatus taskStatus;
  final List<Task> tasks;

  TaskCount({required this.taskStatus, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final count = tasks.where((task) => task.status == taskStatus).length;

    return Column(
      children: [
        TaskStatusIcon(taskStatus),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color: Black
          ),
        ),
        Text(
          taskStatus.toString().split('.').last.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color: Black
          ),
        ),
      ],
    );
  }
}
