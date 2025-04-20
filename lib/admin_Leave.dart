import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Admin_Leave extends StatefulWidget {
  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<Admin_Leave> {
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
        data =
            pendingData.where((item) => item['Status'] == 'Pending').toList();
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

  Future<void> _status(
      String idd, String Reason, String Startdate, String Status) async {
    final response = await http.post(
      Uri.parse('https://creativecollege.in/Flutter/Leave_status.php'),
      body: {
        'ID': idd.trim(),
        'reason': Reason.trim(),
        'startdate': Startdate.trim(),
        'Status': Status.trim()
      },
    );

    Fluttertoast.showToast(
      msg: response.body,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
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
              child: ListView.builder(
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
                          style: TextStyle(color: Colors.black), // Black text
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reason: ${data[index]['Reason']}',
                                style: TextStyle(color: Colors.black)), // Black text
                            Text('Start Date: ${data[index]['Start_Date']}',
                                style: TextStyle(color: Colors.black)), // Black text
                            Text('Last Date: ${data[index]['Last_Date']}',
                                style: TextStyle(color: Colors.black)), // Black text
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
                                    String id = data[index]['SL'];
                                    String Status = 'Rejected';
                                    _status(id, reason, startDate, Status)
                                        .then((value) => {fetchData()});
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: Text('Reject',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    String reason = data[index]['Reason'];
                                    String startDate = data[index]['Start_Date'];
                                    String id = data[index]['SL'];
                                    String Status = 'Approved';
                                    _status(id, reason, startDate, Status)
                                        .then((value) => {fetchData()});
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: Text('Approve',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (index < data.length - 1) Divider(color: Colors.grey), // Grey divider
                    ],
                  );
                },
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