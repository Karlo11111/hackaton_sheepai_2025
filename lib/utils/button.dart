// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key,
      required this.buttonText,
      required this.ontap,
      required this.height});

  final Function()? ontap;
  final String buttonText;
  final double height;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Color.fromARGB(255, 82, 174, 48),
        ),
        alignment: Alignment.center,
        height: height,
        child: Text(
          buttonText,
          style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
