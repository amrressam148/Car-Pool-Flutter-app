import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import 'login_screen.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({Key? key}) : super(key: key);

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final carModelTextEditingController = TextEditingController();
  final carNumberTextEditingController = TextEditingController();
  final carColorTextEditingController = TextEditingController();
  final carBrandTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  _submit() {
    if (_formKey.currentState!.validate()) {
      Map driverCarInfoMap = {
        "car_model": carModelTextEditingController.text.trim(),
        "car_color": carColorTextEditingController.text.trim(),
        "car_number": carNumberTextEditingController.text.trim(),
        "car_brand": carBrandTextEditingController.text.trim(),
      };
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
          "drivers");
      userRef.child(currentUser!.uid).child("car_details").set(
          driverCarInfoMap);
      Fluttertoast.showToast(
        msg: 'Car Info has been saved',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(
                  'images/carpool_logo.png',
                  width: 250,
                  height: 150,
                  fit: BoxFit.scaleDown,
                ),
                Text(
                  'Add Car Info',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: carModelTextEditingController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Car Model",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.directions_car,
                                  color: Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Car Model cannot be empty';
                                }
                                if (text.length < 2) {
                                  return 'Please enter a valid Car Model';
                                }
                                if (text.length > 49) {
                                  return 'Car Model cannot exceed 50 characters';
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: carNumberTextEditingController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Car Number",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.confirmation_number,
                                  color: Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Car Number cannot be empty';
                                }
                                if (text.length < 2) {
                                  return 'Please enter a valid Car Number';
                                }
                                if (text.length > 49) {
                                  return 'Car Number cannot exceed 50 characters';
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: carColorTextEditingController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Car Color",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.color_lens,
                                  color: Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Car Color cannot be empty';
                                }
                                if (text.length < 2) {
                                  return 'Please enter a valid Car Color';
                                }
                                if (text.length > 49) {
                                  return 'Car Color cannot exceed 50 characters';
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: carBrandTextEditingController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Car Brand",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.car_rental,
                                  color: Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Car Brand cannot be empty';
                                }
                                if (text.length < 2) {
                                  return 'Please enter a valid Car Brand';
                                }
                                if (text.length > 49) {
                                  return 'Car Brand cannot exceed 50 characters';
                                }
                              },
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity, // Match the width of the parent container
                              height: 50, // Set the desired height
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  _submit();
                                },

                                child: Text(
                                  'Submit',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
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
}