import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Get a reference to the Hive box
    final box = Hive.box('myBox');
    final money = box.get('money', defaultValue: 0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OTP logo and logout button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Image(
                    image: AssetImage('assets/icons/otpBankLogo.png', ),
                    width: 200,
                    ),


                  const Spacer(),
                  const Icon(Icons.mail, size: 40,color: Colors.white),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _signOut(context),
                    child: const Icon(Icons.logout, size: 40,color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                "Pozdrav Antonio!",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Tekući račun",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Stanje",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
                ),
              ),

              const SizedBox(height: 6),

              // 👇 Displaying user money from Hive
              Text(
                "${money.toStringAsFixed(2)} €",
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
