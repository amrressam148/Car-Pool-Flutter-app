import 'package:drivers/screens/GoFacultyScreen.dart';
import 'package:drivers/screens/GoHomeScreen.dart';
import 'package:drivers/screens/ProfileScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

//import 'GoHomeScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? driverId; // Store the driver ID

  @override
  void initState() {
    super.initState();
    fetchDriverId();
  }

  Future<void> fetchDriverId() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      // Assuming your drivers are stored under a "drivers" collection in Firestore
      DatabaseReference driversRef =
      FirebaseDatabase.instance.reference().child('drivers');
      DatabaseEvent event = await driversRef.child(user.uid).once();

      DataSnapshot snapshot = event.snapshot;


      if (snapshot.value != null) {
        // The user is a driver, set the driverId
        setState(() {
          driverId = user.uid;
        });
      } else {
        // Handle the case where the user is not a driver
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/bg-1.jpg"),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 65, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "With Confidence",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Our CarPool app fosters a seamless journey for students, "
                      "bringing them together to share rides and sidestep all transportation hiccups,"
                      "ensuring an enjoyable travel experience for all.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoHomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(20),
                          ),
                          child: Text(
                            'Go Home',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoFacultyScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(20),
                          ),
                          child: Text(
                            'Go Faculty',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            FirebaseAuth auth = FirebaseAuth.instance;
            User? user = auth.currentUser;

            if (user != null) {
              String userId = user.uid;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(userId: userId),
                ),
              );
            } else {
              // Handle when no user is logged in
              // For instance, show a dialog to prompt the user to log in or handle it as per your app flow
            }
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.person),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}