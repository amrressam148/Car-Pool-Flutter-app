import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RequestsScreen extends StatefulWidget {
  final String tripId;
  final String sourceScreen;
  final String pickUpTime;

  RequestsScreen({
    required this.tripId,
    required this.sourceScreen,
    required this.pickUpTime,
  });

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<String> userIds = []; // Store user IDs associated with the trip
  Map<String, Map<String, dynamic>> usersData = {}; // Store user ID and corresponding user data
  bool enforceTimeConstraints = true;
  @override
  void initState() {
    super.initState();
    fetchBookedUsers();
  }


  Future<void> fetchBookedUsers() async {
    try {
      final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

      DatabaseReference bookedTripsRef = databaseReference.child('booked_trips');

      DatabaseEvent event = await bookedTripsRef.once();

      DataSnapshot dataSnapshot = event.snapshot;

      Map<dynamic, dynamic>? tripsData = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (tripsData != null) {
        tripsData.forEach((userId, userData) {
          if (userData.containsKey(widget.tripId)) {
            userIds.add(userId);
          }
        });

        fetchUserData();
      }
    } catch (error) {
      print('Error fetching booked users: $error');
    }
  }

  Future<void> fetchUserData() async {
    try {
      final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

      for (var userId in userIds) {
        DatabaseReference userRef = databaseReference.child('users/$userId');

        DatabaseEvent event = await userRef.once();

        DataSnapshot dataSnapshot = event.snapshot;
        Map<dynamic, dynamic>? userData = dataSnapshot.value as Map<dynamic, dynamic>?;

        if (userData != null) {
          Map<String, dynamic> userMap = {
            'name': userData['name'],
            'address': userData['address'],
            'phone': userData['phone'],
          };
          usersData[userId] = userMap;
        }
      }

      setState(() {});
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> updateTripStatus(String userId, String status) async {

    if(status == 'accepted' || status == 'declined' || status == 'finished') {

      final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

      DatabaseReference bookedTripRef = databaseReference
          .child('booked_trips/$userId/${widget.tripId}');

      await bookedTripRef.update({
        'status': status
      });
    }

    setState(() {});
  }
  void removeUserCard(String userId) {
    setState(() {
      userIds.remove(userId); // Remove the user ID from the list of displayed users
      usersData.remove(userId); // Remove the user's data from the map
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Requests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Users who booked this trip:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Enforce Time Constraints'),
                Switch(
                  value: enforceTimeConstraints,
                  onChanged: (newValue) {
                    setState(() {
                      enforceTimeConstraints = newValue;
                    });
                  },
                ),
              ],
            ),

            Expanded(
              child: usersData.isNotEmpty
                  ? ListView.builder(
                itemCount: userIds.length,
                itemBuilder: (context, index) {
                  String userId = userIds[index];
                  Map<String, dynamic> userData = usersData[userId] ?? {};

                  String userName = userData['name'] ?? '';
                  String userAddress = userData['address'] ?? '';
                  String userPhoneNumber = userData['phone'] ?? '';

                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(userName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: $userAddress'),
                          Text('Phone: $userPhoneNumber'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle_outline, color: Colors.green),
                            onPressed: () {
                              if (enforceTimeConstraints){
                                DateTime pickupDateTime = DateTime.parse(widget.pickUpTime);

                                if (widget.sourceScreen == 'GoFaculty') {
                                  DateTime constraintTime = DateTime(pickupDateTime.year, pickupDateTime.month, pickupDateTime.day - 1, 23, 30);

                                  if (DateTime.now().isAfter(constraintTime)) {
                                    Fluttertoast.showToast(
                                      msg: 'Time constraint: Cannot accept or decline after 11:30 PM previous day',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );

                                    return; // Prevent further action
                                  }
                                  else{
                                    // If the time constraints are not violated, perform the accept action
                                    updateTripStatus(userId, 'accepted');
                                    removeUserCard(userId);
                                  }

                                } else if (widget.sourceScreen == 'GoHome') {
                                  DateTime constraintTime = DateTime(
                                      pickupDateTime.year, pickupDateTime.month,
                                      pickupDateTime.day, 16, 30);

                                  if (DateTime.now().isAfter(constraintTime)) {
                                    // Show a message indicating the time constraint
                                    Fluttertoast.showToast(
                                      msg: 'Time constraint: Cannot accept or decline after 4:30 PM same day',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return; // Prevent further action
                                  }
                                  else {
                                    // If the time constraints are not violated, perform the accept action
                                    updateTripStatus(userId, 'accepted');
                                    removeUserCard(userId);
                                  }
                                }

                              }
                              else{
                                updateTripStatus(userId, 'accepted');
                                removeUserCard(userId);
                              }


                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              if (enforceTimeConstraints){
                                DateTime pickupDateTime = DateTime.parse(widget.pickUpTime);

                                if (widget.sourceScreen == 'GoFaculty') {
                                  DateTime constraintTime = DateTime(pickupDateTime.year, pickupDateTime.month, pickupDateTime.day - 1, 23, 30);

                                  if (DateTime.now().isAfter(constraintTime)) {
                                    Fluttertoast.showToast(
                                      msg: 'Time constraint: Cannot accept or decline after 11:30 PM previous day',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );

                                    return; // Prevent further action
                                  }
                                  else{
                                    // If the time constraints are not violated, perform the accept action
                                    updateTripStatus(userId, 'accepted');
                                    removeUserCard(userId);
                                  }

                                } else if (widget.sourceScreen == 'GoHome') {
                                  DateTime constraintTime = DateTime(
                                      pickupDateTime.year, pickupDateTime.month,
                                      pickupDateTime.day, 16, 30);

                                  if (DateTime.now().isAfter(constraintTime)) {
                                    // Show a message indicating the time constraint
                                    Fluttertoast.showToast(
                                      msg: 'Time constraint: Cannot accept or decline after 4:30 PM same day',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return; // Prevent further action
                                  }
                                  else {
                                    // If the time constraints are not violated, perform the accept action
                                    updateTripStatus(userId, 'decline');
                                    removeUserCard(userId);
                                  }
                                }

                              }
                              else{
                                updateTripStatus(userId, 'decline');
                                removeUserCard(userId);
                              }


                            },
                          ),

                        ],
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text('No users have booked this trip.'),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
