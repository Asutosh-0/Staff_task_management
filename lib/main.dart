import 'package:flutter/material.dart';
// import 'package:flutter_application_1/mobile/mob_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_task_management/mobile/mob_splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 0, 127, 139),
          fontFamily: GoogleFonts.lato().fontFamily),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 900) {
            // For mobile devices
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const Mob_Splash_screen(),
              themeMode: ThemeMode.light,
              theme: ThemeData(
                  primaryColor: const Color.fromARGB(255, 0, 127, 139),
                  fontFamily: GoogleFonts.lato().fontFamily),
              darkTheme: ThemeData(brightness: Brightness.dark),
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              // home:  ,
              home: const Mob_Splash_screen(),
              themeMode: ThemeMode.light,
              theme: ThemeData(
                  primaryColor: const Color.fromARGB(255, 0, 127, 139),
                  fontFamily: GoogleFonts.lato().fontFamily),
              darkTheme: ThemeData(brightness: Brightness.dark),
            );
          }
        },
      ),
    );
  }
}