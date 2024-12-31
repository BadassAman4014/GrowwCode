import 'dart:async';
import 'package:flutter/material.dart';
import 'package:growwcode/login/welcome_screen.dart';
import '../Homepage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8DF8E), Colors.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: Duration(seconds: 5),
            curve: Curves.easeInOut,
            height: 250.0,
            width: 250.0,
            child: Image.asset('assets/images/combined_logo.png'), // Replace with your logo image
          ),
        ),
      ),
    );
  }
}
