import 'package:drivers/global/global.dart';
import 'package:drivers/screens/car_info_screen.dart';
import 'package:drivers/screens/login_screen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  //declare global key
  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    // validate all the form fields
      if (_formKey.currentState!.validate()) {
        // Perform additional validation for email format
        String email = emailTextEditingController.text.trim().toLowerCase();
        if (!email.endsWith('@eng.asu.edu.eg')) {
          Fluttertoast.showToast(
            msg: 'Please use an engineering student email from Ain Shams University (@eng.asu.edu.eg).',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      try {
        await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).then((auth) async {
          currentUser = auth.user;

          if (currentUser != null) {
            Map userMap = {
              "id": currentUser!.uid,
              "name": nameTextEditingController.text.trim(),
              "email": emailTextEditingController.text.trim(),
              "address": addressTextEditingController.text.trim(),
              "phone": phoneTextEditingController.text.trim(),
            };
            DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("drivers");
            userRef.child(currentUser!.uid).set(userMap);
          }

          await Fluttertoast.showToast(
            msg: 'Registered Successfully!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.push(context, MaterialPageRoute(builder: (c) => CarInfoScreen()));
        }).catchError((error) {
          String errorMessage = 'An error occurred: $error';

          if (error is FirebaseAuthException) {
            if (error.code == 'email-already-in-use') {
              errorMessage = 'The email address is already in use.';
            }
          }

          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        });
      } catch (error) {
        Fluttertoast.showToast(
          msg: 'An error occurred: $error',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Not all fields are valid',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      // removing the focus from the input field when the user taps elsewhere on the screen
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
                  width: 250, // Set the desired width
                  height: 150, // Set the desired height
                  fit: BoxFit.scaleDown, // Optional: Adjust the fit of the image within the dimensions
                ),

                Text(
                  'Register',
                  style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
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
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Name",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                  ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400: Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Name Cannot be empty';
                                }
                                if(text.length < 2){
                                  return 'Please Enter a Valid name';
                                }
                                if(text.length > 49){
                                  return 'Name cannot be more than 50';
                                }
                              },
                              onChanged: (text) => setState(() {
                                nameTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 8,),


                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                ),
                                prefixIcon: Icon(Icons.email, color: darkTheme ? Colors.amber.shade400: Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Email Cannot be empty';
                                }
                                if(text.length < 2){
                                  return 'Please Enter a Valid email';
                                }
                                if(EmailValidator.validate(text) == true)
                                {
                                  return null;
                                }
                                if(text.length > 99){
                                  return 'Email cannot be more than 100';
                                }
                              },
                              onChanged: (text) => setState(() {
                                emailTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 8,),

                            IntlPhoneField(
                              showCountryFlag: true,
                              dropdownIcon: Icon(
                                Icons.arrow_drop_down,

                                 color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                              ),
                              decoration: InputDecoration(
                                hintText: "Phone Number",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                              ),
                                prefixIcon: Icon(Icons.phone, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                              ),
                              initialCountryCode: 'EG',
                              onChanged: (text) => setState(() {
                                phoneTextEditingController.text = text.completeNumber;
                              }),
                            ),
                            SizedBox(height: 8,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Address",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                ),
                                prefixIcon: Icon(Icons.location_on, color: darkTheme ? Colors.amber.shade400: Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Address Cannot be empty';
                                }
                                if(text.length < 2){
                                  return 'Please Enter a Valid address';
                                }
                                if(text.length > 99){
                                  return 'address cannot be more than 50';
                                }
                              },
                              onChanged: (text) => setState(() {
                                addressTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 8,),

                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                ),
                                prefixIcon: Icon(Icons.lock, color: darkTheme ? Colors.amber.shade400: Colors.grey,),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: darkTheme ? Colors.amber.shade400: Colors.grey,
                                  ),
                                    onPressed:(){
                                        setState(() {
                                          _passwordVisible = ! _passwordVisible;

                                    });
                                      }
                                )
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Password Cannot be empty';
                                }
                                if(text.length < 6){
                                  return 'Please Enter a Valid password';
                                }
                                if(text.length > 49){
                                  return 'Password cannot be more than 50';
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                passwordTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 8,),


                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.black45: Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )
                                  ),
                                  prefixIcon: Icon(Icons.lock, color: darkTheme ? Colors.amber.shade400: Colors.grey,),
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: darkTheme ? Colors.amber.shade400: Colors.grey,
                                      ),
                                      onPressed:(){
                                        setState(() {
                                          _passwordVisible = ! _passwordVisible;

                                        });
                                      }
                                  )
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Password Cannot be empty';
                                }
                                if(text != passwordTextEditingController.text){
                                  return 'Password do not match';
                                }
                                if(text.length < 6){
                                  return 'Please Enter a Valid password';
                                }
                                if(text.length > 49){
                                  return 'Password cannot be more than 50';
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                confirmTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),

                            SizedBox(
                              width: double.infinity, // Match the width of the parent container
                              height: 50, // Set the desired height
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                  onPrimary: darkTheme ? Colors.black : Colors.white,
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
                            SizedBox(height: 8,),
                            GestureDetector(
                              onTap: (){},
                              child: Text(
                                'Forget Password?',
                                style: TextStyle(
                                    color: darkTheme ? Colors.amber.shade400 : Colors.blue
                                )
                              ),
                            ),

                            SizedBox(height: 20,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Have an account already?",
                                  style:TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 18,
                                  ) ,
                                ),

                                SizedBox(height: 15,width: 10,),

                                GestureDetector(
                                  onTap: (){
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your LoginScreen
                                    );

                                  },
                                  child: Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontSize: 18,
                                        color: darkTheme ? Colors.amber.shade400 : Colors.blue
                                    ),

                                  )
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
  void _registerUser() {
    // Here, perform the registration logic, e.g., save to database, Firebase, etc.
    // If successful, show toast and potentially navigate to a new screen.
    Fluttertoast.showToast(
      msg: 'Registered Successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  // @override
  // void dispose() {
  //   nameTextEditingController.dispose();
  //   // ... dispose other controllers
  //   super.dispose();
  // }

}
