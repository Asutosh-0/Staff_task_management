import 'dart:async';
import 'package:flutter/material.dart';
import 'package:staff_task_management/admin_home.dart';
import 'package:staff_task_management/mobile/mob_login.dart';
import 'package:staff_task_management/mobile/mob_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mob_Splash_screen extends StatefulWidget {
  const Mob_Splash_screen({Key? key});

  @override
  State<Mob_Splash_screen> createState() => _Mob_Splash_screenState();
}

class _Mob_Splash_screenState extends State<Mob_Splash_screen> {
  String animatedText = "";
  String fullText = "Developed By TechnoCrat";
  int textIndex = 0;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    startTypewriterAnimation();
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
          MaterialPageRoute(builder: (context) => Mob_Login_Page()),
        );
      }
    });
  }

  void startTypewriterAnimation() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (textIndex < fullText.length) {
        setState(() {
          animatedText += fullText[textIndex];
          textIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Colors.black,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                Image.asset('assets/images/Creative.gif'),
                const SizedBox(height: 210),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      animatedText,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      "assets/images/technocart.png",
                      height: 30,
                      width: 30,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
