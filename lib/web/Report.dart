import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Report_web extends StatefulWidget {
  @override
  _Report createState() => _Report();
}

class _Report extends State<Report_web> {
  File? _selectedFile;
  bool _isLoading = false;

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

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
        Fluttertoast.showToast(
          msg: 'Unsupported file format. Please select a PDF file.',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      print('No file selected');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Upload'),
        backgroundColor: Colors.black, // Black AppBar
      ),
      backgroundColor: Colors.white, // White background
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.black) // Black indicator
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _selectedFile != null
                ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_upload, color: Colors.black), // Black icon
                    SizedBox(width: 8),
                    Text(
                      'File Name: ${_selectedFile!.path.split('/').last}',
                      style: TextStyle(fontSize: 16, color: Colors.black), // Black text
                    ),
                  ],
                ),
              ],
            )
                : Text('No file selected', style: TextStyle(color: Colors.black)), // Black text
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black button
                foregroundColor: Colors.white,
              ),
              child: Text('Select File'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black button
                foregroundColor: Colors.white,
              ),
              child: Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> uploadFile(File file) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://creativecollege.in/Flutter/Report/upload.php'),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      file.path,
    ),
  );

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'File uploaded successfully',
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