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

class DetailsMobile extends StatefulWidget {
  @override
  _DetailsMobileState createState() => _DetailsMobileState();
}

class _DetailsMobileState extends State<DetailsMobile> {
  List<Task> tasks = [];
  late List<Task> originalTasks = [];
  TaskStatus filter = TaskStatus.all;
  DateTime selectedDate = DateTime.now();
  DateTime lastWeek = DateTime.now().subtract(const Duration(days: 7));
  DateTime? selectedMonth;
  int selectedFilterIndex = 0;
  XFile? _pickedImage;
  late String pickedImagePath;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
        _pickedImage = XFile(savedImagePath);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    loadImagePath();
  }

  String name = '';
  String designation = '';

  Future<void> initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.get(
        Uri.parse('https://creativecollege.in/Flutter/Profile.php?id=$userID'));

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.get(Uri.parse(
        'https://creativecollege.in/Flutter/Task_Details.php?id=$userID'));

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
    final bgColor = isSelected ? Colors.blue : Colors.white;
    final textColor = isSelected ? Colors.white : Colors.black;

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: Colors.black),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Work Details',
                style: TextStyle(color: Colors.white),
              ),
              background: Container(color: Colors.black),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 300,
        backgroundColor: Colors.grey[200], // Changed background color
        child: ListView(
          children: [
            ListTile(
              title: const Text("All", style: TextStyle(color: Colors.black)),
              selected: filter == TaskStatus.all,
              onTap: () {
                setFilter(TaskStatus.all);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Active", style: TextStyle(color: Colors.black)),
              selected: filter == TaskStatus.active,
              onTap: () {
                setFilter(TaskStatus.active);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Pending", style: TextStyle(color: Colors.black)),
              selected: filter == TaskStatus.pending,
              onTap: () {
                setFilter(TaskStatus.pending);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Completed", style: TextStyle(color: Colors.black)),
              selected: filter == TaskStatus.completed,
              onTap: () {
                setFilter(TaskStatus.completed);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      drawerEnableOpenDragGesture: false, // Disables swipe-to-open
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _navigateToAddTaskScreen(context);
        },
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFilterOptions(),
          const SizedBox(height: 20),
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Column(
      children: tasks.map((task) => _buildTaskItem(task)).toList(),
    );
  }

  Widget _buildTaskItem(Task task) {
    return FadeInUp(
      child: Card(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${task.status.toString().split('.').last}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${task.date}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Start Date: ${task.startDate}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'End Date: ${task.endDate}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
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
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

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
  final String title;
  final TaskStatus status;
  final String date;
  final String startDate;
  final String endDate;

  Task(this.title, this.status, this.date, this.startDate, this.endDate);
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
        color = Colors.green;
        break;
      case TaskStatus.completed:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case TaskStatus.pending:
        iconData = Icons.circle;
        color = Colors.red;
        break;
      default:
        iconData = Icons.circle;
        color = Colors.grey;
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          taskStatus.toString().split('.').last.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}