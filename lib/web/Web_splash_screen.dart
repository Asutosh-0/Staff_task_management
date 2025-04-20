import 'dart:async';
import 'package:flutter/material.dart';
import 'package:staff_task_management/admin_home.dart';
import 'package:staff_task_management/web/web_login.dart';
import 'package:staff_task_management/web/web_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Web_SplashScreen extends StatefulWidget {
  const Web_SplashScreen({Key? key});

  @override
  State<Web_SplashScreen> createState() => _Web_SplashScreenState();
}

class _Web_SplashScreenState extends State<Web_SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool isLoggedInAdmin = prefs.getBool('isLoggedInAdmin') ?? false;

    Timer(const Duration(seconds: 3), () {
      if (isLoggedIn) {
        if (isLoggedInAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeNav()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavPage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Web_Login_Page()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height, // Added maximum height
        color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(), // Spacer to push content down
                Expanded(
                  flex: 2,
                  child: Image.asset('assets/images/Creative.gif'),
                ),
                Spacer(), // Spacer for space between widgets
                Expanded(
                  flex: 1,
                  child: AnimatedText(),
                ),
                Spacer(), // Spacer for space between widgets
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Developed By TechnoCrat ",
                      style: TextStyle(color: Colors.white),
                    ),
                    Image.asset(
                      "assets/images/technocart.png",
                      height: 30,
                      width: 30,
                    ),
                  ],
                ),
                Spacer(), // Spacer to push content up
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  const AnimatedText({Key? key}) : super(key: key);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String _displayedText = "";
  final String _fullText = "Welcome to Our Web Application";
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: const TextStyle(fontSize: 24, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }
}