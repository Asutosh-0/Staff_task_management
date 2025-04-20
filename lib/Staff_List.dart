import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_application_1/web/admin_details.dart';
// import 'package:flutter_application_1/mobile/Report_retrive.dart';
import 'package:animate_do/animate_do.dart';
import 'package:staff_task_management/mobile/Report_retrive.dart';
import 'package:staff_task_management/web/admin_details.dart';

class StaffList extends StatefulWidget {
  const StaffList({Key? key}) : super(key: key);

  @override
  State<StaffList> createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
  List<dynamic> items = [];

  Future<void> fetchData() async {
    var url = Uri.parse('https://creativecollege.in/Flutter/staff_list.php');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        items = json.decode(response.body);
        items.sort((a, b) => a['name'].compareTo(b['name']));
      });
    } else {
      print('Failed to load data');
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Staff List',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: 100 * index),
                  child: StaffCard(item: items[index]),
                );
              },
              childCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final Map<String, dynamic> item;

  StaffCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // Set card background to white
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            item['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Set text color to black
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white, // Set dialog background to white
                    title: Text(
                      '${item['name']}\nWork Status & Monthly Report',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), // Set text color to black
                    ),
                    content: const SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Select an option to view details or report.', style: TextStyle(color: Colors.black)), // Set text color to black
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details_admin_web(
                                name: item['name'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Set button background to black
                        ),
                        child: const Text('Status', style: TextStyle(color: Colors.white)), // Set text color to white
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Report_Retrive(
                                id: item['user_name'],
                                name: item['name'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Set button background to black
                        ),
                        child: const Text('Report', style: TextStyle(color: Colors.white)), // Set text color to white
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Set button background to black
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Show Status', style: TextStyle(color: Colors.white)), // Set text color to white
          ),
        ),
      ),
    );
  }
}