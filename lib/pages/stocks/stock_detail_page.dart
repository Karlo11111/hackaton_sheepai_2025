import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class StocksTradePage extends StatefulWidget {
  const StocksTradePage({super.key});

  @override
  State<StocksTradePage> createState() => _StocksTradePageState();
}

class _StocksTradePageState extends State<StocksTradePage> {
  List<Map<String, dynamic>> _stocksList = [];
  List<Map<String, dynamic>> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final List<Map<String, String>> _recentlyViewed = [
    {'symbol': 'AAPL', 'change': '2.45%'},
    {'symbol': 'MSFT', 'change': '1.87%'},
    {'symbol': 'GOOGL', 'change': '0.92%'},
    {'symbol': 'TSLA', 'change': '3.21%'},
  ];

  // Popular stock symbols to fetch
  final List<String> _popularStocks = [
    'AAPL',
    'MSFT',
    'GOOGL',
    'AMZN',
    'TSLA',
    'META',
    'NVDA',
    'NFLX',
    'AMD',
    'INTC',
    'CRM',
    'ORCL',
    'ADBE',
    'PYPL',
    'DIS',
    'BA',
    'JPM',
    'BAC',
    'WMT',
    'PG',
    'JNJ',
    'V',
    'MA',
    'HD'
  ];

  @override
  void initState() {
    super.initState();
    fetchStocksData();
  }

  Future<void> fetchStocksData() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> stocksData = [];

      // Fetch stock data in batches to avoid rate limiting
      for (int i = 0; i < _popularStocks.length; i += 5) {
        List<String> batch = _popularStocks.sublist(
            i, i + 5 > _popularStocks.length ? _popularStocks.length : i + 5);

        List<Map<String, dynamic>> batchData = await fetchStockBatch(batch);
        stocksData.addAll(batchData);

        // Small delay to respect rate limits
        if (i + 5 < _popularStocks.length) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      setState(() {
        _stocksList = stocksData;
        _filteredList = stocksData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching stocks: $e");
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stocks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchStockBatch(
      List<String> symbols) async {
    List<Map<String, dynamic>> results = [];

    for (String symbol in symbols) {
      try {
        // Using Yahoo Finance API endpoint
        final url = 'https://query1.finance.yahoo.com/v8/finance/chart/$symbol';

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['chart'] != null &&
              data['chart']['result'] != null &&
              data['chart']['result'].isNotEmpty) {
            final result = data['chart']['result'][0];
            final meta = result['meta'];
            final quote = result['indicators']['quote'][0];

            // Get the latest price data
            final prices = quote['close'] as List?;
            final volumes = quote['volume'] as List?;
            final highs = quote['high'] as List?;
            final lows = quote['low'] as List?;

            if (prices != null && prices.isNotEmpty) {
              // Filter out null values and ensure we have valid data
              final validPrices = prices
                  .where((p) => p != null)
                  .map((p) => p.toDouble())
                  .toList();

              if (validPrices.isNotEmpty) {
                final currentPrice = validPrices.last;
                final previousPrice = validPrices.length > 1
                    ? validPrices[validPrices.length - 2]
                    : currentPrice;
                final change = currentPrice - previousPrice;
                final changePercent =
                    previousPrice != 0 ? (change / previousPrice) * 100 : 0.0;

                // Safely get volume, high, and low values
                final volume = volumes?.isNotEmpty == true
                    ? (volumes!.last?.toInt() ?? 0)
                    : 0;
                final highPrice = highs?.isNotEmpty == true
                    ? (highs!.last?.toDouble() ?? currentPrice)
                    : currentPrice;
                final lowPrice = lows?.isNotEmpty == true
                    ? (lows!.last?.toDouble() ?? currentPrice)
                    : currentPrice;

                results.add({
                  'symbol': symbol,
                  'name': _getCompanyName(symbol),
                  'currentPrice': currentPrice,
                  'volume': volume,
                  'currency': meta['currency'] ?? 'USD',
                  'exchange': meta['exchangeName'] ?? 'NASDAQ',
                  'changePercent': changePercent.toStringAsFixed(2),
                  'change': change.toStringAsFixed(2),
                  'highPrice': highPrice,
                  'lowPrice': lowPrice,
                });
              }
            }
          }
        }
      } catch (e) {
        print("Error fetching $symbol: $e");
        // Continue with other stocks even if one fails
      }
    }

    return results;
  }

  String _getCompanyName(String symbol) {
    // Map of stock symbols to company names
    const Map<String, String> companyNames = {
      'AAPL': 'Apple Inc.',
      'MSFT': 'Microsoft Corporation',
      'GOOGL': 'Alphabet Inc.',
      'AMZN': 'Amazon.com, Inc.',
      'TSLA': 'Tesla, Inc.',
      'META': 'Meta Platforms, Inc.',
      'NVDA': 'NVIDIA Corporation',
      'NFLX': 'Netflix, Inc.',
      'AMD': 'Advanced Micro Devices, Inc.',
      'INTC': 'Intel Corporation',
      'CRM': 'Salesforce, Inc.',
      'ORCL': 'Oracle Corporation',
      'ADBE': 'Adobe Inc.',
      'PYPL': 'PayPal Holdings, Inc.',
      'DIS': 'The Walt Disney Company',
      'BA': 'The Boeing Company',
      'JPM': 'JPMorgan Chase & Co.',
      'BAC': 'Bank of America Corporation',
      'WMT': 'Walmart Inc.',
      'PG': 'The Procter & Gamble Company',
      'JNJ': 'Johnson & Johnson',
      'V': 'Visa Inc.',
      'MA': 'Mastercard Incorporated',
      'HD': 'The Home Depot, Inc.',
    };

    return companyNames[symbol] ?? symbol;
  }

  void _filterSearch(String query) {
    final filtered = _stocksList.where((stock) {
      final symbol = stock['symbol']!.toLowerCase();
      final name = stock['name']!.toLowerCase();
      return symbol.contains(query.toLowerCase()) ||
          name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredList = filtered;
    });
  }

  String _formatPrice(double price, String currency) {
    if (currency == 'USD') {
      return '\$${price.toStringAsFixed(2)}';
    } else if (currency == 'EUR') {
      return '€${price.toStringAsFixed(2)}';
    } else if (currency == 'CHF') {
      return 'CHF ${price.toStringAsFixed(2)}';
    } else {
      return '${price.toStringAsFixed(2)} $currency';
    }
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toString();
    }
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
                      // Back button and title
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          Text(
                            'Stocks Trading',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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
                            hintText: "Search stocks...",
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
                                  final stock = _recentlyViewed[index];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(stock['symbol']!,
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          '▲ ${stock['change']}',
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

                      // Stocks count and list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Stocks: ${_filteredList.length}",
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          IconButton(
                            onPressed: fetchStocksData,
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final stock = _filteredList[index];
                            final bool isPositive =
                                (double.tryParse(stock['changePercent']) ?? 0) >
                                    0;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isPositive ? Colors.green : Colors.red,
                                  child: Text(
                                    stock['symbol'].length >= 2
                                        ? stock['symbol'].substring(0, 2)
                                        : stock['symbol'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stock['symbol']!,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      stock['name']!,
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${stock['exchange']} • Vol: ${_formatVolume(stock['volume'])}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      'H: ${_formatPrice(stock['highPrice'], stock['currency'])} • L: ${_formatPrice(stock['lowPrice'], stock['currency'])}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatPrice(stock['currentPrice'],
                                          stock['currency']),
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isPositive
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          color: isPositive
                                              ? Colors.green
                                              : Colors.red,
                                          size: 16,
                                        ),
                                        Text(
                                          '${stock['changePercent']}%',
                                          style: GoogleFonts.inter(
                                            color: isPositive
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Navigate to stock detail page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StockDetailPage(stock: stock),
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

// Stock Detail Page
class StockDetailPage extends StatefulWidget {
  final Map<String, dynamic> stock;

  const StockDetailPage({super.key, required this.stock});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  List<FlSpot> _pricePoints = [];
  final TextEditingController _moneyController =
      TextEditingController(text: "100");
  double _moneyToInvest = 100.0;
  bool _isLoadingChart = true;

  @override
  void initState() {
    super.initState();
    fetchStockChartData();
    // Initialize the money to invest from the controller's text
    _moneyToInvest = double.tryParse(_moneyController.text) ?? 100.0;
  }

  Future<void> fetchStockChartData() async {
    setState(() => _isLoadingChart = true);

    try {
      final symbol = widget.stock['symbol'];
      // Fetch 30 days of daily data for the chart
      final url =
          'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=30d';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['chart'] != null &&
            data['chart']['result'] != null &&
            data['chart']['result'].isNotEmpty) {
          final result = data['chart']['result'][0];
          final quotes = result['indicators']['quote'][0];
          final closes = quotes['close'] as List?;

          if (closes != null) {
            final points = <FlSpot>[];

            for (int i = 0; i < closes.length; i++) {
              if (closes[i] != null) {
                points.add(FlSpot(i.toDouble(), closes[i].toDouble()));
              }
            }

            setState(() {
              _pricePoints = points;
              _isLoadingChart = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching chart data: $e");
      setState(() => _isLoadingChart = false);
    }
  }

  Future<void> _buyStock() async {
    try {
      final box = await Hive.openBox('myBox');
      final investmentBalance =
          (box.get('investmentBalance', defaultValue: 0) as num).toDouble();
      final symbol = widget.stock['symbol'];
      final price = widget.stock['currentPrice'];
      final sharesToBuy = _moneyToInvest / price;

      if (_moneyToInvest > investmentBalance) {
        _showSnackBar(
            'Not enough investment balance! You need ${_moneyToInvest.toStringAsFixed(2)} but have ${investmentBalance.toStringAsFixed(2)}',
            Colors.red);
        return;
      }

      final currentShares = box.get('${symbol}_shares', defaultValue: 0.0);
      final currentTotal = box.get('${symbol}_total_spent', defaultValue: 0.0);
      final newShares = currentShares + sharesToBuy;
      final newTotal = currentTotal + _moneyToInvest;

      await box.put('investmentBalance', investmentBalance - _moneyToInvest);
      await box.put('${symbol}_shares', newShares);
      await box.put('${symbol}_total_spent', newTotal);

      _showSnackBar(
          'Bought ${sharesToBuy.toStringAsFixed(4)} shares of $symbol for ${_moneyToInvest.toStringAsFixed(2)}',
          Colors.green);
      setState(() {});
    } catch (e) {
      _showSnackBar('Error buying stock: $e', Colors.red);
    }
  }

  Future<void> _sellStock() async {
    try {
      final box = await Hive.openBox('myBox');
      final symbol = widget.stock['symbol'];
      final sharesOwned = box.get('${symbol}_shares', defaultValue: 0.0);
      final price = widget.stock['currentPrice'];
      final sharesToSell = _moneyToInvest / price;
      final maxSellValue = sharesOwned * price;

      if (_moneyToInvest > maxSellValue) {
        _showSnackBar(
            'Not enough shares to sell! Max you can sell: ${maxSellValue.toStringAsFixed(2)} (${sharesOwned.toStringAsFixed(4)} shares)',
            Colors.red);
        return;
      }

      final currentTotal = box.get('${symbol}_total_spent', defaultValue: 0.0);
      final avgBuyPrice = sharesOwned > 0 ? currentTotal / sharesOwned : 0.0;

      final remainingShares = sharesOwned - sharesToSell;
      final remainingTotal = avgBuyPrice * remainingShares;

      final investmentBalance =
          (box.get('investmentBalance', defaultValue: 0) as num).toDouble();

      await box.put('${symbol}_shares', remainingShares);
      await box.put('${symbol}_total_spent', remainingTotal);
      await box.put('investmentBalance', investmentBalance + _moneyToInvest);

      final profit = _moneyToInvest - (avgBuyPrice * sharesToSell);
      final profitText = profit >= 0 ? 'Profit' : 'Loss';

      _showSnackBar(
          'Sold ${sharesToSell.toStringAsFixed(4)} shares of $symbol for ${_moneyToInvest.toStringAsFixed(2)} ($profitText: ${profit.abs().toStringAsFixed(2)})',
          profit >= 0 ? Colors.green : Colors.red);
      setState(() {});
    } catch (e) {
      _showSnackBar('Error selling stock: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatPrice(double price, String currency) {
    if (currency == 'USD') {
      return '${price.toStringAsFixed(2)}';
    } else if (currency == 'EUR') {
      return '€${price.toStringAsFixed(2)}';
    } else if (currency == 'CHF') {
      return 'CHF ${price.toStringAsFixed(2)}';
    } else {
      return '${price.toStringAsFixed(2)} $currency';
    }
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive =
        (double.tryParse(widget.stock['changePercent']) ?? 0) > 0;
    final symbol = widget.stock['symbol'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          symbol,
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
                    // Company info
                    Text(
                      "Company: ${widget.stock['name']}",
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      "Exchange: ${widget.stock['exchange']}",
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 10),

                    // User's holdings
                    FutureBuilder(
                      future: Hive.openBox('myBox'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final box = Hive.box('myBox');
                          final investmentBalance =
                              (box.get('investmentBalance', defaultValue: 0)
                                      as num)
                                  .toDouble();
                          final shares =
                              box.get('${symbol}_shares', defaultValue: 0.0);
                          final totalSpent = box.get('${symbol}_total_spent',
                              defaultValue: 0.0);
                          final avgPrice =
                              shares > 0 ? totalSpent / shares : 0.0;
                          final currentValue =
                              shares * widget.stock['currentPrice'];
                          final totalProfitLoss = currentValue - totalSpent;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Portfolio',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Investment Balance: ${_formatPrice(investmentBalance, 'USD')}',
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),
                                Text(
                                  'Shares Owned: ${shares.toStringAsFixed(4)}',
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),
                                if (shares > 0) ...[
                                  Text(
                                    'Avg Buy Price: ${_formatPrice(avgPrice, widget.stock['currency'])}',
                                    style:
                                        GoogleFonts.inter(color: Colors.white),
                                  ),
                                  Text(
                                    'Current Value: ${_formatPrice(currentValue, widget.stock['currency'])}',
                                    style:
                                        GoogleFonts.inter(color: Colors.white),
                                  ),
                                  Text(
                                    'Total P/L: ${_formatPrice(totalProfitLoss.abs(), widget.stock['currency'])} (${totalProfitLoss >= 0 ? '+' : '-'}${((totalProfitLoss / totalSpent) * 100).abs().toStringAsFixed(2)}%)',
                                    style: GoogleFonts.inter(
                                      color: totalProfitLoss >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Stock price info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock Information',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Current Price: ${_formatPrice(widget.stock['currentPrice'], widget.stock['currency'])}",
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 16),
                          ),
                          Row(
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: isPositive ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Change: ${widget.stock['changePercent']}% (${_formatPrice(double.parse(widget.stock['change']), widget.stock['currency'])})",
                                style: GoogleFonts.inter(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Day High: ${_formatPrice(widget.stock['highPrice'], widget.stock['currency'])}",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          Text(
                            "Day Low: ${_formatPrice(widget.stock['lowPrice'], widget.stock['currency'])}",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          Text(
                            "Volume: ${_formatVolume(widget.stock['volume'])}",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price chart
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30-Day Price Chart',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _isLoadingChart
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(50),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _pricePoints.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(50),
                                        child: Text(
                                          'Chart data unavailable',
                                          style: GoogleFonts.inter(
                                              color: Colors.white70),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 200,
                                      child: LineChart(
                                        LineChartData(
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: _pricePoints,
                                              isCurved: true,
                                              belowBarData:
                                                  BarAreaData(show: false),
                                              dotData:
                                                  const FlDotData(show: false),
                                              color: isPositive
                                                  ? Colors.green
                                                  : Colors.red,
                                              barWidth: 2,
                                            ),
                                          ],
                                          titlesData:
                                              const FlTitlesData(show: false),
                                          gridData: FlGridData(
                                            show: true,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                strokeWidth: 1,
                                              );
                                            },
                                            getDrawingVerticalLine: (value) {
                                              return FlLine(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          borderData: FlBorderData(show: false),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trading section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trade $symbol',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _moneyController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Amount to invest (\$)',
                              labelStyle:
                                  GoogleFonts.inter(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              prefixStyle:
                                  GoogleFonts.inter(color: Colors.white),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _moneyToInvest = double.tryParse(value) ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You will get: ${(_moneyToInvest / widget.stock['currentPrice']).toStringAsFixed(4)} shares',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price per share: ${_formatPrice(widget.stock['currentPrice'], widget.stock['currency'])}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _moneyToInvest <= 0 ? null : _buyStock,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'BUY',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _moneyToInvest <= 0 ? null : _sellStock,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'SELL',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
