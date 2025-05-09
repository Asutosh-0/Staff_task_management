import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_task_management/admin_home.dart';
import 'package:staff_task_management/web/web_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../consts.dart';
import 'package:http/http.dart' as http;

class Web_Login_Page extends StatefulWidget {
  const Web_Login_Page({super.key});

  @override
  State<Web_Login_Page> createState() => _Web_Login_PageState();
}

class _Web_Login_PageState extends State<Web_Login_Page> {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('https://creativecollege.in/Flutter/Login.php'),
        body: {
          'user': user.text,
          'pass': pass.text,
        },
      );

      if (response.statusCode == 200) {
        if (response.body == 'Success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('userID', user.text);
          prefs.setString('password', pass.text);

          setState(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavPage()),
              result: MaterialPageRoute(builder: (context) => NavPage()),
            );
          });
        } else if (response.body == 'Admin') {
          Fluttertoast.showToast(
            msg: 'Login Successful',
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setBool('isLoggedInAdmin', true);
          prefs.setString('userID', user.text);
          prefs.setString('password', pass.text);

          setState(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeNav()),
              result: MaterialPageRoute(builder: (context) => HomeNav()),
            );
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Invalid username or password. Please try again.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Server error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          height: double.maxFinite,
          color: Colors.black, // Black background
          child: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
      Expanded(
      child: Image.asset(
      webImage,
        color: Colors.white, // White image
        colorBlendMode: BlendMode.srcIn,
      ),
    ),
    Expanded(
    child: Container(
    constraints: const BoxConstraints(maxWidth: 400),
    padding: const EdgeInsets.symmetric(horizontal: 100),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    Container(
    width: 400,
    height: 100,
    padding: EdgeInsets.only(bottom: 20),
    child: Image.asset(
    image2,
    color: Colors.white, // White logo
    colorBlendMode: BlendMode.srcIn,
    ),
    ),
    const Text(
    'Welcome back',
    textAlign: TextAlign.center,
    style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 17,
    color: Colors.white, // White text
    ),
    ),
    const SizedBox(height: 8),
    const Text(
    "Please , Login",
    textAlign: TextAlign.center,
    style: TextStyle(
    fontSize: 23,
    color: Colors.white, // White text
    fontWeight: FontWeight.w700,
    ),
    ),
    const SizedBox(height: 35),
    Form(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    TextFormField(
    controller: user,
    keyboardType: TextInputType.text,
    style: const TextStyle(color: Colors.white), // White input text
    decoration: InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 25.0),
    filled: true,
    hintText: "User Name",
    hintStyle: TextStyle(color: Colors.grey),
    prefixIcon: IconButton(
    onPressed: () {},
    icon: SvgPicture.asset(userIcon, color: Colors.white), // White icon
    ),
    fillColor: Colors.grey[900], // Dark grey input
    border: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(36),
    ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter username';
    }
    return null;
    },
    ),
    const SizedBox(height: 10),
    TextFormField(
    controller: pass,
    obscureText: true,
    keyboardType: TextInputType.text,
    style: const TextStyle(color: Colors.white), // White input text
    decoration: InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 25.0),
    filled: true,
    hintText: "Password",
    hintStyle: TextStyle(color: Colors.grey),
    prefixIcon: IconButton(
    onPressed: () {},
    icon: SvgPicture.asset(keyIcon, color: Colors.white), // White icon
    ),
    fillColor: Colors.grey[900], // Dark grey input
    border: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(36),
    ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter the password';
    }
    return null;
    },
    ),
    ],
    ),
    ),
    SizedBox(height: size.height * 0.014),
    CupertinoButton(
    child: Container(
    alignment: Alignment.center,
    width: 160,
    height: 50,
    decoration: BoxDecoration(
    color: Colors.white, // White button
    borderRadius: BorderRadius.circular(37),
    ),
    child: const Text(
    "Login",
    style: TextStyle(
    color: Colors.black, // Black text
    fontWeight: FontWeight.w700,
    fontSize: 24,
    ),
    ),
    ),
    onPressed: () async {
    await _login();
    },
    ),
    SizedBox(height: size.height * 0.014),
    SvgPicture.asset("assets/icons/deisgn.svg", color:Colors.white,), // white svg
    Container(
    padding: EdgeInsets.zero,
    child: Container(
    alignment: Alignment.center,
    width: double.infinity,
    height: size.height * 0.080,
    decoration: BoxDecoration(
    boxShadow: const [
    BoxShadow(
    blurRadius: 45,
    spreadRadius: 0,
    color: Color.fromRGBO(120, 37, 139, 0.25),
    offset: Offset(0, 25),
    ),
    ],
    borderRadius: BorderRadius.circular(15),
    color: Colors.grey[850], // Dark grey container
    ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "In case you can face any problem then contact Our Technical Team ",
            style: TextStyle(
              color: Colors.grey, // Grey text
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ),
    ),
    ),
    ],
    ),
    ),
    ),
        ],
      ),
          ),
          ),
      ),
    );
  }
}