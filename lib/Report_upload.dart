import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_application_1/mobile/pdfView.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_task_management/mobile/pdfView.dart';

class Report_upload extends StatefulWidget {
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report_upload> {
  File? _selectedFile;
  bool _isLoading = false;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');

    if (userID == null) {
      throw Exception('UserID not found in SharedPreferences');
    }

    var url = Uri.parse('https://creativecollege.in/Flutter/Retrive_Report.php');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> allItems = json.decode(response.body);

      List<dynamic> filteredItems =
      allItems.where((item) => item['ID'] == userID).toList();
      setState(() {
        items = filteredItems;
      });

      return filteredItems;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedFile != null) {
      String fileExtension = _selectedFile!.path.split('.').last.toLowerCase();

      if (fileExtension == 'pdf') {
        await uploadFile(_selectedFile!);
      } else {
        _showToast(
            'Unsupported file format. Please select a PDF file.', Colors.red);
      }
    } else {
      _showToast('No file selected', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    const _color1 = Colors.black;
    const bgColor = Colors.grey;
    return Scaffold(
      backgroundColor: bgColor[200],
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            backgroundColor: _color1,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Monthly Reports',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _isLoading
                      ? CircularProgressIndicator()
                      : FileUploader(
                    selectedFile: _selectedFile,
                    onSelectFile: _selectFile,
                    onUploadFile: _uploadFile,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 3,
                          shadowColor: _color1,
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(items[index]['Filename'].toString()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Uploaded : ${items[index]['Month']} ${items[index]['Year']}'),
                              ],
                            ),
                            onTap: () {
                              String name = items[index]['Filename'].toString();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewer(
                                    url:
                                    "https://creativecollege.in/Flutter/Report/Pdflist.php?name=$name",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FileUploader extends StatelessWidget {
  final File? selectedFile;
  final VoidCallback onSelectFile;
  final VoidCallback onUploadFile;

  List<dynamic> items = [];

  Future<void> fetchData() async {
    var url =
    Uri.parse('https://creativecollege.in/Flutter/Retrive_Report.php');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      items = json.decode(response.body);
    } else {
      print('Failed to load data');
    }
  }

  FileUploader({
    Key? key,
    required this.selectedFile,
    required this.onSelectFile,
    required this.onUploadFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _color1 = Colors.black;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: _color1,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _color1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (selectedFile != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '     ${selectedFile!.path.split('/').last}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: onSelectFile,
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.white,
                ),
                label: Text(
                  'Select File',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: onUploadFile,
                icon: Icon(
                  Icons.cloud_upload,
                  color: Colors.white,
                ),
                label: Text(
                  'Upload File',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

Future<void> uploadFile(File file) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userID = prefs.getString('userID') ?? '';

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://creativecollege.in/Flutter/Report_Upload.php'),
    );

    request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),);

    request.fields['userId'] = userID;

    var response = await request.send();

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Uploaded Successfully",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to upload file. Status code: ${response.statusCode}',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    Fluttertoast.showToast(
      msg: 'Error uploading file: $error',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}