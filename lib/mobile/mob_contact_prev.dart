import 'dart:io';
import 'package:flutter/material.dart';
import 'package:staff_task_management/ContactEdit.dart';
import 'package:staff_task_management/mobile/mob_Profile.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BorderRadiusGeometry borderRadius;

  const CustomAppBar({required this.title, required this.borderRadius});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: const Color(0xFFC21E56),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      elevation: 5,
    );
  }
}

class ContactPrev extends StatefulWidget {
  const ContactPrev({Key? key}) : super(key: key);

  @override
  State<ContactPrev> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPrev> {
  List<String> allowedCourses = ['BSC', 'BCA', 'BBA'];
  XFile? _pickedImage;

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
        _pickedImage = XFile(savedImagePath);
        print("Image loaded from: $savedImagePath"); // Debug print
      } else {
        print("No image path found in SharedPreferences."); // Debug print
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 100.0,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'SELECT COURSE',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
            ),
            actions: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Profile(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: _pickedImage == null
                        ? const AssetImage('assets/images/technocart.png')
                        : _pickedImage != null && File(_pickedImage!.path).existsSync() ? FileImage(File(_pickedImage!.path)) : const AssetImage('assets/images/technocart.png') as ImageProvider<Object>,
                  ),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      for (String course in allowedCourses)
                        _buildCardItem(course, const Color(0xFFDCD8CD), context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(String course, Color cardColor, BuildContext context) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(top: 16),
      elevation: 5,
      child: InkWell(
        onTap: () {
          _navigateToContactPage(course, context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  course,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToContactPage(String course, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Contact(course: course, year: ''),
      ),
    );
  }
}
class Contact extends StatefulWidget {
  final String course;
  final String year;

  Contact({Key? key, required this.course, required this.year})
      : super(key: key);

  @override
  _Contact createState() => _Contact();
}

class _Contact extends State<Contact> {
  int? expandedIndex;
  String selectedYear = '1st'; // Added line to store the selected year

  List<dynamic> data = [];
  String Course = '';
  String Year = '';
  bool isExpanded = false;

  Future<void> fetchDataForYear() async {
    Course = widget.course;
    Year = selectedYear; // Use the selected year
    var url = Uri.parse(
        'https://creativecollege.in/Flutter/StudentContact.php?Course=$Course&Year=$Year');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataForYear();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    String telScheme = 'tel:$phoneNumber';
    if (await canLaunch(telScheme)) {
      await launch(telScheme);
    } else {
      throw 'Could not launch $telScheme';
    }
  }

  Widget _buildYearButton(String label, String year) {
    Color customColor = Colors.black;
    Color innerColor = const Color(0xFFEADFE8);
    Color selectedColor = Colors.black;
    Color textColor = Colors.black;

    if (selectedYear == year) {
      textColor = Colors.white;
    }

    return Container(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedYear = year;
            fetchDataForYear();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedYear == year ? selectedColor : innerColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(color: customColor),
          ),
          elevation: 5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF050505),
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80.0),
                bottomRight: Radius.circular(80.0),
              ),
            ),
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 140.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${widget.course}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Padding(padding: EdgeInsets.all(16.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildYearButton('1st Year', '1st'),
                    _buildYearButton('2nd Year', '2nd'),
                    _buildYearButton('3rd Year', '3rd'),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return FadeInLeft(
                      duration: const Duration(milliseconds: 420),
                      delay: Duration(milliseconds: index * 21),
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        child: Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text('ID: ${data[index]['ID']}',
                                                style: const TextStyle(
                                                    fontSize: 18)),
                                            Text('Name: ${data[index]['NAME']}',
                                                style: const TextStyle(
                                                    fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isExpanded
                                              ? Icons.arrow_drop_up
                                              : Icons.arrow_drop_down,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            expandedIndex =
                                            (expandedIndex == index)
                                                ? null
                                                : index;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  if (expandedIndex == index)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                                'Student No: ${data[index]['MOB_NO']}',
                                                style: const TextStyle(
                                                    fontSize: 18)),
                                            IconButton(
                                              icon: const Icon(Icons.call),
                                              onPressed: () {
                                                String num =
                                                data[index]['MOB_NO'];
                                                CustomSearchDelegate.directCall(
                                                    num);
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                'Father No: ${data[index]['F_MOB']}',
                                                style: const TextStyle(
                                                    fontSize: 18)),
                                            IconButton(
                                              icon: const Icon(Icons.call),
                                              onPressed: () {
                                                String num =
                                                data[index]['F_MOB'];
                                                CustomSearchDelegate.directCall(
                                                    num);
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                'Mother No: ${data[index]['M_MOB']}',
                                                style: const TextStyle(
                                                    fontSize: 18)),
                                            IconButton(
                                              icon: const Icon(Icons.call),
                                              onPressed: () {
                                                String num =
                                                data[index]['M_MOB'];
                                                CustomSearchDelegate.directCall(
                                                    num);
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Contact_Edit(
                                                          course: data[index]
                                                          ['COURSE'] ??
                                                              "Enter new",
                                                          sem: data[index]
                                                          ['SEMESTER'] ??
                                                              "Enter new",
                                                          id: data[index]['ID'] ??
                                                              "Enter new",
                                                          sMob: data[index]
                                                          ['MOB_NO'] ??
                                                              "Enter new",
                                                          mMob: data[index]
                                                          ['M_MOB'] ??
                                                              "Enter new",
                                                          fMob: data[index]
                                                          ['F_MOB'] ??
                                                              "Enter new",
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSearch(
            context: context,
            delegate: CustomSearchDelegate(data: data),
          );
        },
        backgroundColor: Colors.black, // Black background
        foregroundColor: Colors.white, // White icon
        child: const Icon(Icons.search),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> data;

  CustomSearchDelegate({required this.data});

  // Move the directCall method outside the CustomSearchDelegate class
  static directCall(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      color: Colors.black,
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> searchResults = data
        .where((item) =>
            item['ID'].toString().contains(query) ||
            item['NAME'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (searchResults.isEmpty) {
      return Center(
        child: Text('No results found for: $query'),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(16.0),
          child: Card(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${searchResults[index]['ID']}',
                                  style: const TextStyle(fontSize: 18)),
                              Text('Name: ${searchResults[index]['NAME']}',
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            size: 30,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                                'Student No: ${searchResults[index]['MOB_NO']}',
                                style: const TextStyle(fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {
                                String num = searchResults[index]['MOB_NO'];
                                CustomSearchDelegate.directCall(num);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Father No: ${searchResults[index]['F_MOB']}',
                                style: const TextStyle(fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {
                                String num = searchResults[index]['F_MOB'];
                                CustomSearchDelegate.directCall(num);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Mother No: ${searchResults[index]['M_MOB']}',
                                style: const TextStyle(fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {
                                String num = searchResults[index]['M_MOB'];
                                CustomSearchDelegate.directCall(num);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> suggestionResults = data
        .where((item) =>
            item['ID'].toString().contains(query) ||
            item['NAME'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (suggestionResults.isEmpty) {
      return Center(
        child: Text('No suggestions for: $query'),
      );
    }

    return ListView.builder(
      itemCount: suggestionResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            'ID: ${suggestionResults[index]['ID']} - Name: ${suggestionResults[index]['NAME']}',
          ),
          onTap: () {
            query = suggestionResults[index]['ID'].toString();
            showResults(context);
          },
        );
      },
    );
  }
}
