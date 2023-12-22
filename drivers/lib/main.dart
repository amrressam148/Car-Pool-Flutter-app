import 'package:drivers/screens/AddFacultyTripScreen.dart';
import 'package:drivers/screens/AddHomeTripScreen.dart';
import 'package:drivers/screens/GoFacultyScreen.dart';
import 'package:drivers/screens/GoHomeScreen.dart';
import 'package:drivers/screens/car_info_screen.dart';
import 'package:drivers/screens/PaymentScreen.dart';
import 'package:drivers/screens/ProfileScreen.dart';
import 'package:drivers/screens/login_screen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:drivers/screens/register_screen.dart';
import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:drivers/themeProvider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      theme: Mythemes.lightTheme,
      darkTheme: Mythemes.darkTheme,
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    );
  }
}
