import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackaton_sheepai_2025/pages/ChooseInvestmentPage/Widgets/bigCard.dart';
import 'package:hackaton_sheepai_2025/pages/ChooseInvestmentPage/Widgets/card.dart';
import 'package:hackaton_sheepai_2025/pages/cryptoInvestment/crypto_page.dart';
import 'package:hackaton_sheepai_2025/pages/sandboxPage/sanbox_page.dart';
import 'package:hackaton_sheepai_2025/pages/stocks/stocks_page.dart';
import 'package:hackaton_sheepai_2025/pages/tutorialsPage/tutorials_page.dart';

import 'package:hive_flutter/hive_flutter.dart';

class ChooseInvestmentPage extends StatelessWidget {
  const ChooseInvestmentPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('myBox');
    final money = box.get('money', defaultValue: 0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
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
                    image: AssetImage('assets/icons/otpBankLogo.png'),
                    width: 200,
                  ),
                  const Spacer(),
                  const Icon(Icons.mail, size: 40, color: Colors.white),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _signOut(context),
                    child: const Icon(Icons.logout, size: 40, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Stocks and Crypto Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  StocksPage()),
                      );
                    },
                    child: const ItemCard(
                      naslov: 'Stocks',
                      imagePath: 'assets/icons/stocks.png',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  CryptoPage()),
                      );
                    },
                    child: const ItemCard(
                      naslov: 'Crypto',
                      imagePath: 'assets/icons/crypto.png',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const BigCard(),

              const SizedBox(height: 16),

              // Tutorials and Sandbox Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  TutorialsPage()),
                      );
                    },
                    child: const ItemCard(
                      naslov: 'Tutorials',
                      imagePath: 'assets/icons/stocks.png',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  SanboxPage()),
                      );
                    },
                    child: const ItemCard(
                      naslov: 'Sandbox',
                      imagePath: 'assets/icons/stocks.png',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
