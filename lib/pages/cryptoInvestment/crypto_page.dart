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
  List<Map<String, String>> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final List<Map<String, String>> _recentlyViewed = [
    {'symbol': 'BTC', 'change': '1.63%'},
    {'symbol': 'XRP', 'change': '1.69%'},
    {'symbol': 'SOL', 'change': '1.03%'},
    {'symbol': 'DOGE', 'change': '0.53%'},
  ];

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
        _filteredList = result;
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    final filtered = _cryptoList.where((crypto) {
      final symbol = crypto['symbol']!.toLowerCase();
      final base = crypto['baseCoin']!.toLowerCase();
      final quote = crypto['quoteCoin']!.toLowerCase();
      return symbol.contains(query.toLowerCase()) ||
          base.contains(query.toLowerCase()) ||
          quote.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterSearch,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Recently viewed section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Recently viewed:",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _recentlyViewed.length,
                                itemBuilder: (context, index) {
                                  final coin = _recentlyViewed[index];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(coin['symbol']!,
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          '▲ ${coin['change']}',
                                          style: GoogleFonts.inter(
                                              color: Colors.greenAccent,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Crypto count and list
                      Text("Crypto: ${_filteredList.length}",
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final item = _filteredList[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(item['symbol']!,
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${item['baseCoin']} / ${item['quoteCoin']}',
                                  style: GoogleFonts.inter(color: Colors.white70),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white70, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CryptoDetailPage(crypto: item),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
