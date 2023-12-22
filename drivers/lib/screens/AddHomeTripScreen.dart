import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddHomeTripScreen extends StatefulWidget {
  @override
  _AddHomeTripScreenState createState() => _AddHomeTripScreenState();
}

class _AddHomeTripScreenState extends State<AddHomeTripScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _pickupLocationController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _pickUpTimeController = TextEditingController();
  TextEditingController _dropOffTimeController = TextEditingController();

  DateTime _pickUpTime = DateTime.now();
  DateTime _dropOffTime = DateTime.now();

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}  ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Add Trip',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _pickupLocationController.text.isNotEmpty ? _pickupLocationController.text : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            _pickupLocationController.text = newValue ?? '';
                          });
                        },
                        items: <String>['Gate 3', 'Gate 4'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: 'Pick-up Location',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pick-up Location';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          hintText: 'Destination',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter destination';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          hintText: 'Price',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _pickUpTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != _pickUpTime) {
                            final TimeOfDay pickedTime = TimeOfDay(hour: 5, minute: 30); // Set to 7:30 AM

                            setState(() {
                              _pickUpTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              _pickUpTimeController.text = _formatDateTime(_pickUpTime);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _pickUpTimeController,
                            decoration: InputDecoration(
                              hintText: 'Pick-up Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter pick-up time';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _dropOffTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != _dropOffTime) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_dropOffTime),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _dropOffTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                _dropOffTimeController.text = _formatDateTime(_dropOffTime); // Format date and time as needed
                              });
                            }
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dropOffTimeController,
                            decoration: InputDecoration(
                              hintText: 'Drop-off Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter drop-off time';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveTripToFirebase();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue, // Set the background color to blue
                          onPrimary: Colors.white, // Set the text color to white
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Save Trip'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTripToFirebase() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;

      final databaseReference = FirebaseDatabase.instance.reference();

      // Fetching car details
      DatabaseEvent carDetailsEvent = await databaseReference.child('drivers/$userId/car_details').once();
      DataSnapshot carDetailsSnapshot = carDetailsEvent.snapshot;
      Map<dynamic, dynamic>? carDetailsMap = carDetailsSnapshot.value as Map<dynamic, dynamic>?;

      // Fetching name and phone
      DatabaseEvent driverEvent = await databaseReference.child('drivers/$userId').once();
      DataSnapshot driverSnapshot = driverEvent.snapshot;
      Map<dynamic, dynamic>? driverMap = driverSnapshot.value as Map<dynamic, dynamic>?;

      if (carDetailsMap != null && driverMap != null) {
        String carBrand = carDetailsMap['car_brand'];
        String carColor = carDetailsMap['car_color'];
        String driverName = driverMap['name'];
        String driverPhone = driverMap['phone'];

        final newTripRef = databaseReference.child('Go Home Trips/$userId').push();

        final Map<String, dynamic> tripDetails = {
          'User ID': userId,
          'Car Brand': carBrand,
          'Car Color': carColor,
          'Driver Name': driverName,
          'Driver Phone': driverPhone,
          'Pick-up Location': _pickupLocationController.text,
          'Destination': _destinationController.text,
          'Price': double.parse(_priceController.text),
          'Pick-up Time': _pickUpTime.toIso8601String(),
          'Drop-off Time': _dropOffTime.toIso8601String(),
        };

        await newTripRef.set(tripDetails);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip details saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Handle case where specific details for this user ID are not found
        // Display an error or take appropriate action
      }
    } else {
      // Handle when no user is logged in
      // For instance, show a dialog to prompt the user to log in or handle it as per your app flow
    }
  }


  @override
  void dispose() {
    _pickupLocationController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    _pickUpTimeController.dispose();
    _dropOffTimeController.dispose();
    super.dispose();
  }
}