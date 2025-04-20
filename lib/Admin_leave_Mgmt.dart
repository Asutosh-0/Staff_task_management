// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Admin_Leave_Page extends StatefulWidget {
  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<Admin_Leave_Page> {
  TextEditingController reason = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<dynamic> data = [];
  String name = '';

  Future<void> fetchData() async {
    var url = Uri.parse('https://creativecollege.in/Flutter/Leave_Data.php');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> pendingData = json.decode(response.body);
        data = pendingData.where((item) => item['Status'] == 'Pending').toList();
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Error fetching data',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _status(String Reason, String Startdate, String Status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.post(
      Uri.parse('https://creativecollege.in/Flutter/Leave_status.php'),
      body: {
        'ID': userID.trim(),
        'reason': Reason,
        'startdate': Startdate,
        'Status': Status
      },
    );

    Fluttertoast.showToast(
      msg: response.body,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    reason.text = '';
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.black, // Black app bar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: Text(
              'Leave Request',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            floating: false,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: data.length > 0
                  ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          'Name: ${data[index]['Name']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black), // Black Text
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reason: ${data[index]['Reason']}', style: TextStyle(color: Colors.black)), // Black Text
                            Text('Start Date: ${data[index]['Start_Date']}', style: TextStyle(color: Colors.black)), // Black Text
                            Text('Last Date: ${data[index]['Last_Date']}', style: TextStyle(color: Colors.black)), // Black Text
                            Text(
                              'Status: ${data[index]['Status']}',
                              style: TextStyle(
                                color: getStatusColor(data[index]['Status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    String reason = data[index]['Reason'];
                                    String startDate = data[index]['Start_Date'];
                                    String Status = 'Rejected';
                                    _status(reason, startDate, Status)
                                        .then((value) => {fetchData()});
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text('Reject', style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    String reason = data[index]['Reason'];
                                    String startDate = data[index]['Start_Date'];
                                    String Status = 'Approved';
                                    _status(reason, startDate, Status)
                                        .then((value) => {fetchData()});
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: Text('Approve', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (index < data.length - 1) Divider(color: Colors.grey), // Grey Divider
                    ],
                  );
                },
              )
                  : Center(
                child: Text(
                  'No Leave Application',
                  style: TextStyle(fontSize: 18, color: Colors.black), // Black Text
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.red;
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.black;
  }
}