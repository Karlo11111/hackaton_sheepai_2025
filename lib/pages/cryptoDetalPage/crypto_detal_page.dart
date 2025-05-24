import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackaton_sheepai_2025/models/Ticker.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class CryptoDetailPage extends StatefulWidget {
  final Map<String, String> crypto;

  const CryptoDetailPage({super.key, required this.crypto});

  @override
  State<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends State<CryptoDetailPage> {
  List<FlSpot> _pricePoints = [];
  Ticker? _ticker;
  final TextEditingController _amountController =
      TextEditingController(text: "1");
  double _amountToBuy = 1.0;

  @override
  void initState() {
    super.initState();
    fetchKlineData();
    fetchTickerData();
  }

  Future<void> fetchKlineData() async {
    final symbol = widget.crypto['symbol'];
    final url =
        'https://api.bybit.com/v5/market/kline?category=spot&symbol=$symbol&interval=60&limit=30';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    final List kline = data['result']['list'];
    final points = <FlSpot>[];

    for (int i = 0; i < kline.length; i++) {
      final candle = kline[i];
      double time = i.toDouble();
      double close = double.parse(candle[4]);
      points.add(FlSpot(time, close));
    }

    setState(() => _pricePoints = points);
  }

  Future<void> fetchTickerData() async {
    final symbol = widget.crypto['symbol'];
    final response = await http.get(
        Uri.parse('https://api.bybit.com/v5/market/tickers?category=spot'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tickers = data['result']['list'];

      for (var item in tickers) {
        if (item['symbol'] == symbol) {
          setState(() {
            _ticker = Ticker.fromJson(item);
          });
          break;
        }
      }
    }
  }

  Future<void> _buyCrypto() async {
    final box = await Hive.openBox('myBox');
    final money = box.get('money');
    final coin = widget.crypto['baseCoin'];
    final price = _ticker!.lastPrice;
    final totalCost = price * _amountToBuy;

    if (totalCost > money) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough money!')),
      );
      return;
    }

    final currentAmount = box.get('${coin}_amount', defaultValue: 0.0);
    final currentTotal = box.get('${coin}_total_spent', defaultValue: 0.0);
    final newAmount = currentAmount + _amountToBuy;
    final newTotal = currentTotal + totalCost;

    await box.put('money', money - totalCost);
    await box.put('${coin}_amount', newAmount);
    await box.put('${coin}_total_spent', newTotal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Bought $_amountToBuy $coin for \$${totalCost.toStringAsFixed(2)}')),
    );

    setState(() {});
  }

  Future<void> _sellCrypto() async {
    final box = await Hive.openBox('myBox');
    final coin = widget.crypto['baseCoin'];
    final amountOwned = box.get('${coin}_amount', defaultValue: 0.0);
    final price = _ticker!.lastPrice;

    if (_amountToBuy > amountOwned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins to sell!')),
      );
      return;
    }

    final currentTotal = box.get('${coin}_total_spent', defaultValue: 0.0);
    final avgBuyPrice = currentTotal / amountOwned;
    final sellValue = price * _amountToBuy;

    final remainingAmount = amountOwned - _amountToBuy;
    final remainingTotal = avgBuyPrice * remainingAmount;

    await box.put('${coin}_amount', remainingAmount);
    await box.put('${coin}_total_spent', remainingTotal);
    await box.put('money', box.get('money') + sellValue);

    final profit = sellValue - (avgBuyPrice * _amountToBuy);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sold $_amountToBuy $coin for \$${sellValue.toStringAsFixed(2)} (Profit/Loss: \$${profit.toStringAsFixed(2)})',
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.crypto['baseCoin'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.crypto['symbol'] ?? 'Crypto',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 42, 43, 46),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Base: $coin",
                        style: const TextStyle(color: Colors.white)),
                    Text("Quote: ${widget.crypto['quoteCoin']}",
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: Hive.openBox('myBox'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final box = Hive.box('myBox');
                          final money = box.get('money', defaultValue: 0.0);
                          final coinAmount =
                              box.get('${coin}_amount', defaultValue: 0.0);
                          final coinSpent =
                              box.get('${coin}_total_spent', defaultValue: 0.0);
                          final avgPrice =
                              coinAmount > 0 ? coinSpent / coinAmount : 0.0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Money: \$${money.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  'You own: ${coinAmount.toStringAsFixed(4)} $coin',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  'Avg Buy Price: \$${avgPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _ticker != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Price: ${_ticker!.lastPrice.toStringAsFixed(2)} USD",
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  "24h Change: ${_ticker!.price24hPcnt.toStringAsFixed(2)}%",
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  "24h High: ${_ticker!.highPrice24h.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  "24h Low: ${_ticker!.lowPrice24h.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  "24h Volume: ${_ticker!.volume24h.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 20),
                    _pricePoints.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _pricePoints,
                                    isCurved: true,
                                    belowBarData: BarAreaData(show: false),
                                    dotData: const FlDotData(show: false),
                                    color: Colors.orange,
                                  ),
                                ],
                                titlesData: const FlTitlesData(show: false),
                                gridData: const FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Amount of $coin to buy',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _amountToBuy = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _ticker != null
                        ? Text(
                            'You need: \$${(_ticker!.lastPrice * _amountToBuy).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white),
                          )
                        : const SizedBox(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_ticker == null || _amountToBuy <= 0)
                                ? null
                                : _buyCrypto,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                            child: const Text('Buy'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_ticker == null || _amountToBuy <= 0)
                                ? null
                                : _sellCrypto,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Sell'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
