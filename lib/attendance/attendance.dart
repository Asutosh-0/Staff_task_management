import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Attendance extends StatefulWidget {
  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  String selectedCourse = 'BBA';
  String selectedSemesterGroup = '1st';
  Map<String, dynamic>? allData;
  Map<String, dynamic>? filteredData;
  DateTime currentDate = DateTime.now();
  Map<String, Map<String, dynamic>> attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        allData = data;
        filteredData = _filterData(data, selectedCourse, selectedSemesterGroup);
        _initializeAttendanceStatus(filteredData);
      });
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://creativecollege.in/Flutter/New_attendance/Fetch_student_data.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

    Map<String, dynamic> _filterData(
      Map<String, dynamic> data, String course, String semesterGroup) {
    final filtered = <String, dynamic>{};
    data.forEach((key, records) {
      final sortedRecords = (records as List<dynamic>)
          .where((record) {
            final semester = record['SEMESTER'];
            if (semesterGroup == '1st') {
              return ['1st', '2nd'].contains(semester) &&
                  record['COURSE'] == course;
            } else if (semesterGroup == '2nd') {
              return ['3rd', '4th'].contains(semester) &&
                  record['COURSE'] == course;
            } else if (semesterGroup == '3rd') {
              return ['5th', '6th'].contains(semester) &&
                  record['COURSE'] == course;
            }
            return false;
          })
          .toList()
          ..sort((a, b) => a['NAME'].compareTo(b['NAME'])); // Sorting by name A-Z

      filtered[key] = sortedRecords;
    });
    return filtered;
  }

  // Map<String, dynamic> _filterData(
  //     Map<String, dynamic> data, String course, String semesterGroup) {
  //   final filtered = <String, dynamic>{};
  //   data.forEach((key, records) {
  //     filtered[key] = (records as List<dynamic>).where((record) {
  //       final semester = record['SEMESTER'];
  //       if (semesterGroup == '1st') {
  //         return ['1st', '2nd'].contains(semester) &&
  //             record['COURSE'] == course;
  //       } else if (semesterGroup == '2nd') {
  //         return ['3rd', '4th'].contains(semester) &&
  //             record['COURSE'] == course;
  //       } else if (semesterGroup == '3rd') {
  //         return ['5th', '6th'].contains(semester) &&
  //             record['COURSE'] == course;
  //       }
  //       return false;
  //     }).toList();
  //   });
  //   return filtered;
  // }

  void _initializeAttendanceStatus(Map<String, dynamic>? data) {
    final status = <String, Map<String, dynamic>>{};
    if (data != null) {
      data.values.expand((records) => records).forEach((record) {
        status[record['ID']] = {
          'name': record['NAME'],
          'id': record['ID'],
          'present': false,
        };
      });
    }
    setState(() {
      attendanceStatus = status;
    });
  }

  void _toggleAttendance(String id) {
    setState(() {
      final student = attendanceStatus[id];
      if (student != null) {
        student['present'] = !student['present'];
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != currentDate) {
      setState(() {
        currentDate = picked;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (attendanceStatus.isEmpty) return;

    final url = Uri.parse(
      'https://creativecollege.in/Flutter/New_attendance/attendance.php',
    );

    final List<Map<String, dynamic>> attendanceList =
    attendanceStatus.values.map((student) {
      return {
        'id': student['id'],
        'present': student['present'] ? 1 : 0,
        'date': DateFormat('yyyy-MM-dd').format(currentDate),
        'semester_group': selectedSemesterGroup,
        'course': selectedCourse,
      };
    }).toList();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(attendanceList),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
            Text(responseBody['message'] ?? 'Attendance submitted'),
          ));
        } else if (responseBody['status'] == 'error') {
          final errorMessage = responseBody['message'];
          if (errorMessage is List) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(errorMessage.join('\n')),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(errorMessage ?? 'Failed to submit'),
            ));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: HTTP ${response.statusCode}'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   "Date: ${DateFormat('yyyy-MM-dd').format(currentDate)}",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Date: ${DateFormat('yyyy-MM-dd').format(currentDate)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFilterButton('BBA', selectedCourse == 'BBA'),
              _buildFilterButton('BSC-C', selectedCourse == 'BSC-C'),
              _buildFilterButton('BCA', selectedCourse == 'BCA'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFilterButton('1st', selectedSemesterGroup == '1st'),
              _buildFilterButton('2nd', selectedSemesterGroup == '2nd'),
              _buildFilterButton('3rd', selectedSemesterGroup == '3rd'),
            ],
          ),
          Expanded(
            child: filteredData == null
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : filteredData!.isEmpty
                ? Center(child: Text('No data available'))
                : ListView(
              children: filteredData!.values
                  .expand((records) => records)
                  .map<Widget>((record) {
                final id = record['ID'];
                final name = record['NAME'];
                final isPresent =
                    attendanceStatus[id]?['present'] ?? false;

                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          '$name',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        subtitle: Text(
                          'ID: $id',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Checkbox(
                          value: isPresent,
                          onChanged: (bool? value) {
                            if (value != null) {
                              _toggleAttendance(id);
                            }
                          },
                          activeColor: Colors.black,
                          checkColor: Colors.white,
                        ),
                      ),
                      Divider(thickness: 1, color: Colors.grey[700]),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return ElevatedButton(
        onPressed: () {
      setState(() {
        if (text == 'BBA' || text == 'BSC-C' || text == 'BCA') {
          selectedCourse = text;
          filteredData = _filterData(
              allData ?? {}, selectedCourse, selectedSemesterGroup);
          _initializeAttendanceStatus(filteredData);
        } else {
          selectedSemesterGroup = text;
          filteredData = _filterData(
              allData ?? {}, selectedCourse, selectedSemesterGroup);
          _initializeAttendanceStatus(filteredData);
        }
      });
        },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.lightBlueAccent : Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text),
    );
  }
}