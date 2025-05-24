import 'package:flutter/material.dart';


class BigCard extends StatelessWidget {

  const BigCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, 
      height: 180,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 42, 43, 46), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset:  Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset('assets/icons/otpFond.png', width: 300,)
    );
  }
}
