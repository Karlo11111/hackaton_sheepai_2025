import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemCard extends StatelessWidget {
  final String imagePath;
  final String naslov;
 

  const ItemCard({
    super.key,
    required this.naslov,
    required this.imagePath,
    
  });

  @override
  Widget build(BuildContext context) {
    return 
     Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 42, 43, 46),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            Text(
              naslov,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 25),
            Image.asset(imagePath),
            const SizedBox(height: 25),
          ],
        ),
      );
    
  }
}
