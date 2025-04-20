import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String address;
  final String phone;
  final String userName;

  EditProfilePage({
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.userName,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  XFile? _pickedImage;
  late String pickedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _editProfile() async {
    final response = await http.post(
      Uri.parse('https://creativecollege.in/Flutter/EditProfile.php'),
      body: {
        'user': widget.userName,
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
      },
    );

    if (response.statusCode == 200) {
      if (response.body == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile update failed'),
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
    nameController.text = widget.name;
    emailController.text = widget.email;
    usernameController.text = widget.userName;
    phoneController.text = widget.phone;
    addressController.text = widget.address;
  }

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
        _pickedImage = XFile(savedImagePath);
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      pickedImagePath = pickedImage.path;
      await saveImagePath(pickedImagePath);

      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  Future<void> saveImagePath(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pickedImagePath', imagePath);
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
            backgroundColor: _color1,
            floating: false,
            pinned: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: _pickedImage == null
                            ? AssetImage('assets/images/technocart.png')
                            : FileImage(File(_pickedImage!.path))
                        as ImageProvider<Object>?,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInLeft(
                    duration: Duration(milliseconds: 1000),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter New Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInRight(
                    duration: Duration(milliseconds: 1000),
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter New Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.man_sharp),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInLeft(
                    duration: Duration(milliseconds: 1000),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Enter New Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInRight(
                    duration: Duration(milliseconds: 1000),
                    child: TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Enter New Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInLeft(
                    duration: Duration(milliseconds: 1000),
                    child: TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Enter New Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: ElevatedButton(
                      onPressed: () {
                        _editProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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