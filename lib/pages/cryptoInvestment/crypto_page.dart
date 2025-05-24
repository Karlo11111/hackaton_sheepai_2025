import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackaton_sheepai_2025/pages/cryptoDetalPage/crypto_detal_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  List<Map<String, String>> _cryptoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCryptoData();
  }

  Future<void> fetchCryptoData() async {
    const url = 'https://api.bybit.com/v5/market/instruments-info?category=spot';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      final List<Map<String, String>> result = [];
      for (var item in data['result']['list']) {
        result.add({
          'symbol': item['symbol'],
          'baseCoin': item['baseCoin'],
          'quoteCoin': item['quoteCoin'],
        });
      }

      setState(() {
        _cryptoList = result;
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:  AssetImage('assets/images/background.png'),
                fit: BoxFit.cover)
            ),
            child: ListView.builder(
                itemCount: _cryptoList.length,
                itemBuilder: (context, index) {
                  final item = _cryptoList[index];
                  return ListTile(
                    title: Text(item['symbol']!, 
                    style: GoogleFonts.inter(
                      color: Colors.white)  
                      ,),
                    subtitle: Text('${item['baseCoin']} / ${item['quoteCoin']}', style: GoogleFonts.inter(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CryptoDetailPage(crypto: item),
                        ),
                      );
                    },
                  );
                },
              ),
          ),
    );
  }
}
