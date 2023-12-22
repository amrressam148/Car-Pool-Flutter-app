import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Trip {
  final String pickupLocation;
  final String destination;
  final double price;
  final String pickUpTime;
  final String dropOffTime;

  Trip({
    required this.pickupLocation,
    required this.destination,
    required this.price,
    required this.pickUpTime,
    required this.dropOffTime,
  });
}

class PaymentHistoryScreen extends StatefulWidget {
  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTripsFromFirebase();
  }

  Future<void> fetchTripsFromFirebase() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      final databaseReference = FirebaseDatabase.instance.reference();
      DatabaseReference userTripsRef = databaseReference.child('booked_trips/${user.uid}');

      DatabaseEvent event = await userTripsRef.once();

      List<Trip> fetchedTrips = [];
      Map<dynamic, dynamic>? tripsData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (tripsData != null) {
        tripsData.forEach((key, value) {
          Trip trip = Trip(
            pickupLocation: value['pickupLocation'],
            destination: value['destination'],
            price: double.parse(value['price'].toString()),
            pickUpTime: value['pickUpTime'],
            dropOffTime: value['dropOffTime'],
          );
          fetchedTrips.add(trip);
        });
      }

      setState(() {
        trips = fetchedTrips;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Payment History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        controller: ScrollController(),
        thickness: 10.0,
        radius: Radius.circular(20),
        showTrackOnHover: true,
        child: ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripBookingScreen(trip: trips[index]),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4.0,
                  child: ListTile(
                    title: Text(
                      'From: ${trips[index].pickupLocation}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To: ${trips[index].destination}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Pick-up Time: ${trips[index].pickUpTime}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Drop-off Time: ${trips[index].dropOffTime}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

class TripBookingScreen extends StatelessWidget {
  final Trip trip;

  TripBookingScreen({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Previous Trip',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'From: ${trip.pickupLocation}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'To: ${trip.destination}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Pick-up Time: ${trip.pickUpTime}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Drop-off Time: ${trip.dropOffTime}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Price: \$${trip.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'You took this trip at ${trip.pickUpTime} and the expected drop-off time was ${trip.dropOffTime} and the cost was ${trip.price.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
