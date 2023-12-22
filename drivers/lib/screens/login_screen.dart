import 'package:drivers/screens/forget_password_screen.dart';
import 'package:drivers/screens/register_screen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../utilities/database_helper.dart';
import 'main_screen2.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child('drivers/$userId');
    DatabaseEvent event = await userRef.once();
    DataSnapshot dataSnapshot = event.snapshot;


    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> userData =
      dataSnapshot.value as Map<dynamic, dynamic>;
      return userData.cast<String, dynamic>();
    }
    return null;
  }

  void _submit() async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential auth = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        );

        if (auth.user != null) {
          String userId = auth.user!.uid;

          Map<String, dynamic>? userData = await fetchUserData(userId);

          if (userData != null) {

            await DatabaseHelper.insertUser({
              'id': userId,
              'address': userData['address'] ?? '',
              'email': userData['email'] ?? '',
              'name': userData['name'] ?? '',
              'phone': userData['phone'] ?? '',
            });

            currentUser = auth.user;

            Fluttertoast.showToast(
              msg: 'Successfully Logged In',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
          } else {
            Fluttertoast.showToast(
              msg: 'No record exists with this email',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            FirebaseAuth.instance.signOut();
          }
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
    } catch (e) {
      // Handle specific errors that might occur during sign-in
      String errorMessage = 'An error occurred.';

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else {
          errorMessage = 'Error: ${e.message}';
        }
      }

      Fluttertoast.showToast(
        msg: errorMessage,
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
      onTap: (){
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
                  height: 200, // Set the desired height
                  fit: BoxFit.scaleDown, // Optional: Adjust the fit of the image within the dimensions
                ),

                //SizedBox(height:10,),

                Text(
                  'Drivers Login',
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
                                  'Sign in',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            SizedBox(height: 8,),
                            GestureDetector(
                              onTap: (){
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgetPassword()), // Replace with your LoginScreen
                                );
                              },
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
                                  "Doesn't have an account?",
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
                                        MaterialPageRoute(builder: (context) => RegisterScreen()), // Replace with your LoginScreen
                                      );
                                    },
                                    child: Text(
                                      "Sign up",
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
}
