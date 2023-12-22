import 'package:drivers/screens/AddFacultyTripScreen.dart';
import 'package:drivers/screens/PaymentScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'RequestsScreen.dart';

class GoFacultyTrip {
  final String tripId;
  final String pickupLocation;
  final String destination;
  final double price;
  final String pickUpTime;
  final String dropOffTime;

  GoFacultyTrip({
    required this.tripId,
    required this.pickupLocation,
    required this.destination,
    required this.price,
    required this.pickUpTime,
    required this.dropOffTime,
  });
}

class GoFacultyScreen extends StatefulWidget {

  @override
  _GoFacultyScreenState createState() => _GoFacultyScreenState();
}

class _GoFacultyScreenState extends State<GoFacultyScreen> {
  Map<String, bool> tripFinishedStatus = {};
  bool tripFinished = false;
  List<String> tripIds = [];
  Map<String, GoFacultyTrip> tripsData = {};

  @override
  void initState() {
    super.initState();
    fetchDriverTrips();
  }

  Future<void> updateTripStatus(String tripId) async {
    try {
      DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
      DatabaseReference bookedTripsRef = databaseReference.child('booked_trips');

      DatabaseEvent event = await bookedTripsRef.once();
      DataSnapshot dataSnapshot = event.snapshot;


      Map<dynamic, dynamic>? allUsersTrips = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (allUsersTrips != null) {
        allUsersTrips.forEach((userId, userTrips) async {
          if (userTrips != null && userTrips.containsKey(tripId)) {
            DatabaseReference tripRef = bookedTripsRef.child('$userId/$tripId');

            // Update the status of the trip
            await tripRef.update({'status': 'finished'});

            // Update the UI or perform any necessary actions
            setState(() {
                  tripFinishedStatus[tripId] = true;
            });
          }
        });
      }
    } catch (error) {
      print('Error updating trip status: $error');
    }
  }

  Future<void> fetchDriverTrips() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final String userId = user.uid;

        final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

        DatabaseReference driverTripsRef = databaseReference.child('Go Faculty Trips/$userId');

        DatabaseEvent event = await driverTripsRef.once();
        DataSnapshot dataSnapshot = event.snapshot;


        Map<dynamic, dynamic>? trips = dataSnapshot.value as Map<dynamic, dynamic>?;

        if (trips != null) {
          trips.forEach((tripId, tripData) {
            tripIds.add(tripId);
          });

          await fetchTripDetails(userId);
        }
      }
    } catch (error) {
      print('Error fetching driver trips: $error');
    }
  }

  Future<void> fetchTripDetails(String userId) async {
    try {
      final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

      for (var tripId in tripIds) {
        DatabaseReference tripRef = databaseReference.child('Go Faculty Trips/$userId/$tripId');

        DatabaseEvent event = await tripRef.once();
        DataSnapshot dataSnapshot = event.snapshot;

        Map<dynamic, dynamic>? tripData = dataSnapshot.value as Map<dynamic, dynamic>?;

        if (tripData != null) {
          GoFacultyTrip trip = GoFacultyTrip(
            tripId: tripId,
            pickupLocation: tripData['Pick-up Location'] ?? '',
            destination: tripData['Destination'] ?? '',
            price: double.parse(tripData['Price'].toString() ?? '0.0'),
            pickUpTime: tripData['Pick-up Time'] ?? '',
            dropOffTime: tripData['Drop-off Time'] ?? '',
          );

          tripsData[tripId] = trip;
        }
      }

      setState(() {});
    } catch (error) {
      print('Error fetching trip details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Available Trips',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: tripIds.isEmpty
          ? Center(
        child: Text(
          'No trips added recently',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          :  tripsData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: tripIds.length,
        itemBuilder: (context, index) {
          String tripId = tripIds[index];
          GoFacultyTrip trip = tripsData[tripId] ?? GoFacultyTrip(
            tripId: '',
            pickupLocation: '',
            destination: '',
            price: 0.0,
            pickUpTime: '',
            dropOffTime: '',
          );
          
          bool isTripFinished = tripFinishedStatus[tripId] ?? false;
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestsScreen(tripId: tripId,pickUpTime: trip.pickUpTime ,sourceScreen: 'GoFaculty'),
                  ),
                );
              },
              child: Card(
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    'From: ${trip.pickupLocation}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To: ${trip.destination}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pick-up Time: ${trip.pickUpTime}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Drop-off Time: ${trip.dropOffTime}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${trip.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          updateTripStatus(tripId);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: isTripFinished ? Colors.grey : Colors.blue,
                        ),
                        child: Text(
                          isTripFinished ? 'Finished' : 'Finish Trip'
                        ),
                      ),
                    ],
                  ),

                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFacultyTripScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
