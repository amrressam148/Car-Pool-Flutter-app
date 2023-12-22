import 'package:drivers/screens/GoHomeScreen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'GoFacultyScreen.dart';
//import 'GoHomeScreen.dart';
class PaymentScreen extends StatefulWidget {
  final double displayedprice;
  final String displayedpickupLocation; // Updated to individual details
  final String destination; // Updated to individual details
  final String pickUpTime; // Updated to individual details
  final String dropOffTime; // Updated to individual details
  PaymentScreen({
    Key? key,
    required this.displayedprice,
    required this.displayedpickupLocation,
    required this.destination,
    required this.pickUpTime,
    required this.dropOffTime,
  }) : super(key: key);


  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int value = 0;
  int numberOfSeats = 1; // Default number of seats
  List<String> paymentLabels = ['Cash' ,'Pay with Credit Card', 'Pay with Fawry']; // Sample payment labels
  late TextEditingController paymentDetailsController;

  @override
  void initState() {
    super.initState();
    paymentDetailsController = TextEditingController();
  }

  @override
  void dispose() {
    paymentDetailsController.dispose();
    super.dispose();
  }

// Existing code remains the same...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Payment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Center( // Wrapping content with Center widget
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number of Seats:',
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButton<int>(
                    value: numberOfSeats,
                    onChanged: (newValue) {
                      setState(() {
                        numberOfSeats = newValue!;
                      });
                    },
                    items: List.generate(5, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text((index + 1).toString()),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose your payment method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: paymentLabels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Radio(
                      value: index,
                      groupValue: value,
                      onChanged: (i) => setState(() => value = i!),
                    ),
                    title: Text(paymentLabels[index]),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: TextFormField(
                controller: paymentDetailsController,
                decoration: InputDecoration(
                  labelText: getPaymentMethodLabel(),
                  hintText: getPaymentMethodHint(),
                ),
                textAlign: TextAlign.center, // Centering the text input
                style: TextStyle(fontSize: 20), // Adjusting font size
              ),
            ),
            Text(
              'Order Price: \$${widget.displayedprice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(200, 50), // Adjusting button size
              ),
              onPressed: () {
                // Implement booking functionality here
                processPayment();
              },
              child: Text(
                'Place Order',
                style: TextStyle(fontSize: 20), // Adjusting button font size
              ),
            ),
          ],
        ),
      ),
    );
  }


  String getPaymentMethodLabel() {
    switch (value) {
    // case 0:
    //   return 'Enter Credit Card Number';
      case 1:
        return 'Enter Credit Card Number';
      case 2:
        return 'Enter Fawry Mobile Number';
      default:
        return "";
    }
  }

  String getPaymentMethodHint() {
    switch (value) {
      case 0:
        return 'Credit Card Number';
      case 1:
        return 'Mobile Number';
      case 2:
        return 'Google Pay Details';
      default:
        return '';
    }
  }

  void processPayment() {
    if (value == 0) {
      // Credit Card selected, process credit card details
      processCreditCardPayment();
    } else if (value == 1) {
      // PayPal selected, process PayPal details
      processPayPalPayment();
    } else if (value == 2) {
      // Google Pay selected, process Google Pay details
      processGooglePayPayment();
    }
  }

  void processCreditCardPayment() {
    String creditCardNumber = paymentDetailsController.text;
    // Process payment with credit card details
    goToSuccessScreen();
  }

  void processPayPalPayment() {
    String mobileNumber = paymentDetailsController.text;
    // Process payment with PayPal details
    goToSuccessScreen();
  }

  void processGooglePayPayment() {
    String googlePayDetails = paymentDetailsController.text;
    // Process payment with Google Pay details
    goToSuccessScreen();
  }


  void goToSuccessScreen() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

      // Retrieve authenticated user ID
      String userId = user.uid;

      // Store booked trip details under the user's ID
      DatabaseReference userBookedTripsRef = databaseReference.child('booked_trips/$userId');
      userBookedTripsRef.push().set({
        'pickupLocation': widget.displayedpickupLocation,
        'destination': widget.destination,
        'price': widget.displayedprice,
        'pickUpTime': widget.pickUpTime,
        'dropOffTime': widget.dropOffTime,
        // Add more fields as needed
      }).then((value) {
        // Navigate to the success screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Success(),
          ),
        );
      }).catchError((error) {
        print("Failed to book trip: $error");
      });
    } else {
      print('User is not logged in');
    }
  }



}

class Success extends StatefulWidget {
  const Success({super.key});

  @override
  _SuccessState createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("images/success.png"),
              height: 150.0,
            ),
            Text(
              'Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your payment was done successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(150, 50), // Adjusting button size
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ),
                );
              },
              child: Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}