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
  bool _isChecked = false;

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void SignIn() async {
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image sized to fill entire screen
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          

          // Scrollable content on top
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset('assets/icons/otpFond.png', width: 300,)]),


                  Text(
                    "Sign in",
                    style: GoogleFonts.inter(
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Sign in to continue",
                    style: GoogleFonts.inter(
                      fontSize: 17.4,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 30),

                  MyTextField(
                    controller: emailTextController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  SizedBox(height: 20),

                  MyTextField(
                    controller: passwordTextController,
                    hintText: "Password",
                    obscureText: true,
                  ),

                  SizedBox(height: 20),

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
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.inter(
                            color: Color.fromARGB(255, 82, 174, 48),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswd(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  MyButton(
                    buttonText: "Log In",
                    ontap: SignIn,
                    height: 50,
                  ),

                  SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.black,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member yet?",
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.ontap,
                        child: Text(
                          "Register Now!",
                          style: GoogleFonts.inter(
                            color: Color.fromARGB(255, 82, 174, 48),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
