import 'package:car_pool/screens/PaymentScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GoFacultyTrip {
  final String tripId;
  final String pickupLocation;
  final String destination;
  final double price;
  final String pickUpTime;
  final String dropOffTime;
  final String driverName;
  final String driverPhone;
  final String carBrand;
  final String carColor;


  GoFacultyTrip({
    required this.tripId,
    required this.pickupLocation,
    required this.destination,
    required this.price,
    required this.pickUpTime,
    required this.dropOffTime,
    required this.driverName,
    required this.driverPhone,
    required this.carBrand,
    required this.carColor,
  });
}

class GoFacultyScreen extends StatefulWidget {
  @override
  _GoFacultyScreenState createState() => _GoFacultyScreenState();
}

class _GoFacultyScreenState extends State<GoFacultyScreen> {
  late List<GoFacultyTrip> trips = []; // Initialize the trips list
  bool timeConstraintEnabled = true; // Variable to track if time constraints are enabled

  @override
  void initState() {
    super.initState();
    fetchTripsFromFirebase();
  }

  Future<void> fetchTripsFromFirebase() async {
    try {
      final databaseReference = FirebaseDatabase.instance.reference();
      DatabaseEvent event = await databaseReference.child('Go Faculty Trips').once();
      DataSnapshot dataSnapshot = event.snapshot;

      List<GoFacultyTrip> fetchedTrips = [];

      Map<dynamic, dynamic>? tripsData = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (tripsData != null) {
        tripsData.forEach((userId, userTrips) {
          userTrips.forEach((tripKey, tripData) {
            // Exclude 'User ID' from trip data
            Map<String, dynamic> filteredTripData = Map<String, dynamic>.from(tripData);
            filteredTripData.remove('User ID');

            GoFacultyTrip trip = GoFacultyTrip(
              tripId: tripKey,
              pickupLocation: filteredTripData['Pick-up Location'] ?? '',
              destination: filteredTripData['Destination'] ?? '',
              price: double.parse(filteredTripData['Price'].toString() ?? '0.0'),
              pickUpTime: filteredTripData['Pick-up Time'] ?? '',
              dropOffTime: filteredTripData['Drop-off Time'] ?? '',
              driverName: filteredTripData['Driver Name'] ?? '',
              driverPhone: filteredTripData['Driver Phone'] ?? '',
              carBrand: filteredTripData['Car Brand'] ?? '',
              carColor: filteredTripData['Car Color'] ?? '',
            );
            fetchedTrips.add(trip);
          });
        });
      }

      setState(() {
        trips = fetchedTrips;
      });

      // Debugging statements
      print('Fetched Trips Length: ${fetchedTrips.length}');
    } catch (error) {
      print('Error fetching trips: $error');
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
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Time Constraints'),
            value: timeConstraintEnabled,
            onChanged: (value) {
              setState(() {
                timeConstraintEnabled = value;
              });
            },
          ),
          Expanded(
            child: trips.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripBookingScreen(
                            trip: trips[index],
                            timeConstraintEnabled: timeConstraintEnabled, // Pass the value
                          ),
                        ),
                      );
                    },

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
                            Text(
                              'Driver Name: ${trips[index].driverName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Driver Phone: ${trips[index].driverPhone}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Car Brand: ${trips[index].carBrand}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Car color: ${trips[index].carColor}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '\$${trips[index].price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }}


class TripBookingScreen extends StatelessWidget {
  final GoFacultyTrip trip;
  final bool timeConstraintEnabled; // New parameter

  TripBookingScreen({
    required this.trip,
    required this.timeConstraintEnabled, // Updated constructor
  });


  bool canBookTrip() {
    // Check if the time constraint switch is enabled
    if (timeConstraintEnabled) {
      // Get the current date and time
      DateTime now = DateTime.now();

      // Parse the pickup time from the database into a DateTime object
      DateTime tripPickupTime = DateTime.parse(trip.pickUpTime);

      // Define the reservation cutoff time for a trip at 7:30 AM (10:00 PM previous day)
      DateTime reservationCutoff730AM = DateTime(tripPickupTime.year, tripPickupTime.month, tripPickupTime.day - 1, 22, 0);

      // Check if the current time is before the reservation cutoff time
      return now.isBefore(reservationCutoff730AM);
    }

    // If the time constraint switch is disabled, allow booking at any time
    return true;
  }
  @override
  Widget build(BuildContext context) {
    bool canBook = canBookTrip();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Book Trip',
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
            Text(
              'Driver Name: ${trip.driverName}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Driver Phone: ${trip.driverPhone}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Car Brand: ${trip.carBrand}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Car Color: ${trip.carColor}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            if (canBook)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        tripId: trip.tripId,
                        displayedprice: trip.price,
                        displayedpickupLocation: trip.pickupLocation,
                        destination: trip.destination,
                        pickUpTime: trip.pickUpTime,
                        dropOffTime: trip.dropOffTime,
                      ),
                    ),
                  );
                },
                child: Text('Book Now'),
              )
            else
              Text(
                'Booking not available for this trip based on time constraints.',
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
