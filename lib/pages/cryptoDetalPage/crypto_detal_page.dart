import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  final TextEditingController _amountController = TextEditingController(text: "1");
  double _amountToBuy = 1.0;

  @override
  void initState() {
    super.initState();
    fetchKlineData();
    fetchTickerData();
  }

  Future<void> fetchKlineData() async {
    final symbol = widget.crypto['symbol'];
    final url = 'https://api.bybit.com/v5/market/kline?category=spot&symbol=$symbol&interval=60&limit=30';

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
    final response = await http.get(Uri.parse('https://api.bybit.com/v5/market/tickers?category=spot'));

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

    final currentCoinAmount = box.get(coin, defaultValue: 0.0);

    await box.put('money', money - totalCost);
    await box.put(coin, currentCoinAmount + _amountToBuy);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bought $_amountToBuy $coin for \$${totalCost.toStringAsFixed(2)}')),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.crypto['baseCoin'];
    return Scaffold(
      appBar: AppBar(title: Text(widget.crypto['symbol'] ?? 'Crypto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Base: $coin"),
              Text("Quote: ${widget.crypto['quoteCoin']}"),
              const SizedBox(height: 10),
              FutureBuilder(
                future: Hive.openBox('myBox'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final box = Hive.box('myBox');
                    final money = box.get('money', defaultValue: 0);
                    return Text('Money: \$${money.toStringAsFixed(2)}');
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
                        Text("Price: ${_ticker!.lastPrice.toStringAsFixed(2)} USD"),
                        Text("24h Change: ${_ticker!.price24hPcnt.toStringAsFixed(2)}%"),
                        Text("24h High: ${_ticker!.highPrice24h.toStringAsFixed(2)}"),
                        Text("24h Low: ${_ticker!.lowPrice24h.toStringAsFixed(2)}"),
                        Text("24h Volume: ${_ticker!.volume24h.toStringAsFixed(2)}"),
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
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(show: false),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
          
              // 🔽 Input for amount
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount of $coin to buy',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _amountToBuy = double.tryParse(value) ?? 0;
                  });
                },
              ),
          
              const SizedBox(height: 10),
          
              // 🔽 Show computed total cost
              _ticker != null
                  ? Text('Total Cost: \$${(_ticker!.lastPrice * _amountToBuy).toStringAsFixed(2)}')
                  : const SizedBox(),
          
              const SizedBox(height: 10),
          
              ElevatedButton(
                onPressed: (_ticker == null || _amountToBuy <= 0) ? null : _buyCrypto,
                child: const Text('Buy with Local Money'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
