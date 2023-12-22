import 'dart:async';

import 'package:car_pool/screens/login_screen.dart'; // Import your LoginScreen here
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your LoginScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'images/carpool_logo.png', // Replace 'images/splash_image.png' with your image asset path
          width: 250, // Adjust the width as needed
          height: 200, // Adjust the height as needed
          fit: BoxFit.scaleDown, // Optional: Adjust the fit of the image within the dimensions
        ),
      ),
    );
  }
}
