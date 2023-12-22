import 'package:car_pool/screens/GoFacultyScreen.dart';
import 'package:car_pool/screens/PaymentScreen.dart';
import 'package:car_pool/screens/ProfileScreen.dart';
import 'package:car_pool/screens/login_screen.dart';
import 'package:car_pool/screens/main_screen.dart';
import 'package:car_pool/screens/register_screen.dart';
import 'package:car_pool/splashScreen/splash_screen.dart';
import 'package:car_pool/themeProvider/theme_provider.dart';
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
