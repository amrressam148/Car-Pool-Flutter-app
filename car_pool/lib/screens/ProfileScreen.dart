import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utilities/database_helper.dart';
import 'PaymentHistoryScreen.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId; // Pass the user ID to fetch the profile data

  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Fetch user profile data
    fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    Map<String, dynamic> userDataFromSQLite = await DatabaseHelper.getUserData(widget.userId);

    setState(() {
      _nameController.text = userDataFromSQLite['name'] ?? '';
      _emailController.text = userDataFromSQLite['email'] ?? '';
      _phoneController.text = userDataFromSQLite['phone'] ?? '';
      _addressController.text = userDataFromSQLite['address'] ?? '';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement logic to update the user profile data in the database
                updateProfileData();
              },
              child: Text('Save'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Payment History Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentHistoryScreen(),
                      ),
                    );
                  },
                  child: Text('Payment History'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateProfileData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      final databaseReference = FirebaseDatabase.instance.reference();
      DatabaseReference userRef = databaseReference.child('users/${widget.userId}');

      await userRef.set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated!')),
      );
    }
  }
}