import 'package:drivers/screens/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  final emailTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  void _submit() {
    firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text.trim()
    ).then((value) {
      Fluttertoast.showToast(
        msg: 'We have sent an email to recover password',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    });
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
                  'Recover Password',
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
                                 _submit();                                },

                                child: Text(
                                  'Send Password via E-mail ',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),

                            SizedBox(height: 20,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Back to login?",
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
}
