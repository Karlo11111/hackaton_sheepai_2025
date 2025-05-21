// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackaton_sheepai_2025/pages/auth/forgot_password_page.dart';
import 'package:hackaton_sheepai_2025/utils/button.dart';
import 'package:hackaton_sheepai_2025/utils/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.ontap,
  });
  final Function()? ontap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //bool for checkbox
  bool _isChecked = false;

  //controllers for text
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  //sing in function
  void SignIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    //try signing in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      //display if theres and error while logging in
      displayMessage(e.code);
    }
  }

  //dispaly a message with the error
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message),
              ),
            ));
  }

  //the main frontend code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //SIZED BOX
                  SizedBox(height: 50),

                  //TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Sign in",
                          style: GoogleFonts.inter(
                              fontSize: 35,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sign in to continue",
                        style: GoogleFonts.inter(
                            fontSize: 17.4,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                      ),
                    ],
                  ),

                  //SIZED BOX
                  SizedBox(height: 30),

                  //TEXTFIELDS FOR EMAIL AND PASSWD
                  //email
                  MyTextField(
                    controller: emailTextController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  //sized box
                  const SizedBox(height: 20),

                  //passwd
                  MyTextField(
                    controller: passwordTextController,
                    hintText: "Password",
                    obscureText: true,
                  ),

                  //sized box
                  const SizedBox(height: 20),

                  //Rem me&forgot passwd - jos treba funkcionalnost
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: -5,
                          children: [
                            Checkbox(
                              value: _isChecked,
                              onChanged: (bool? value1) {
                                setState(() {
                                  _isChecked = value1!;
                                });
                              },
                            ),
                            Text(
                              "Remember me",
                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300),
                            )
                          ]),
                      GestureDetector(
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.inter(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswd(),
                            ),
                          );
                        },
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //login button
                  MyButton(
                    buttonText: "Log In",
                    ontap: SignIn,
                    height: 50,
                  ),

                  //sized box
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      )),
                    ],
                  ),

                  //TEXT WITH REGISTER PAGE TEXT

                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member yet?",
                        style: GoogleFonts.inter(color: Colors.black),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: widget.ontap,
                          child: Text(
                            "Register Now!",
                            style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
