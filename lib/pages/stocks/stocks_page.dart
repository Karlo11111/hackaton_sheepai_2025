import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  Box? myBox;
  double investmentBalance = 0.0;
  double mainBalance = 0.0;
  bool isLoading = true;
  bool showTopGainers = true; // For the top movers toggle

  // Sample data for top movers
  final List<Map<String, dynamic>> topGainers = [
    {'symbol': 'DOUG', 'percentage': '32.71%', 'color': Color(0xFF4FC3F7)},
    {'symbol': 'MRUS', 'percentage': '32%', 'color': Color(0xFF9E9E9E)},
    {'symbol': 'NNE', 'percentage': '29.85%', 'color': Color(0xFF4CAF50)},
    {'symbol': 'UEC', 'percentage': '25.97%', 'color': Color(0xFF8BC34A)},
    {'symbol': 'INFA', 'percentage': '25.26%', 'color': Color(0xFFFF9800)},
    {'symbol': 'X', 'percentage': '25.13%', 'color': Color(0xFF424242)},
    {'symbol': 'UUUU', 'percentage': '24%', 'color': Color(0xFF2196F3)},
    {'symbol': 'LEU', 'percentage': '21.61%', 'color': Color(0xFFE0E0E0)},
  ];

  final List<Map<String, dynamic>> topLosers = [
    {'symbol': 'AAPL', 'percentage': '-5.23%', 'color': Color(0xFF424242)},
    {'symbol': 'TSLA', 'percentage': '-4.87%', 'color': Color(0xFFE53935)},
    {'symbol': 'NVDA', 'percentage': '-3.45%', 'color': Color(0xFF4CAF50)},
    {'symbol': 'MSFT', 'percentage': '-2.89%', 'color': Color(0xFF2196F3)},
    {'symbol': 'GOOGL', 'percentage': '-2.34%', 'color': Color(0xFFFF9800)},
    {'symbol': 'AMZN', 'percentage': '-1.98%', 'color': Color(0xFFFF5722)},
    {'symbol': 'META', 'percentage': '-1.76%', 'color': Color(0xFF3F51B5)},
    {'symbol': 'NFLX', 'percentage': '-1.23%', 'color': Color(0xFFE91E63)},
  ];

  @override
  void initState() {
    super.initState();
    _loadBalances();
  }

  void _loadBalances() async {
    try {
      myBox = Hive.box('myBox');
      setState(() {
        investmentBalance =
            (myBox!.get('investmentBalance', defaultValue: 1.47) as num)
                .toDouble();
        mainBalance =
            (myBox!.get('money', defaultValue: 0.0) as num).toDouble();

        debugPrint('Available Hive keys: ${myBox!.keys.toList()}');
        debugPrint('Investment balance: $investmentBalance');
        debugPrint('Main balance: $mainBalance');

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading balances: $e');
      try {
        myBox = await Hive.openBox('myBox');
        setState(() {
          investmentBalance =
              (myBox!.get('investmentBalance', defaultValue: 1.47) as num)
                  .toDouble();
          mainBalance =
              (myBox!.get('money', defaultValue: 0.0) as num).toDouble();

          debugPrint(
              'After reopening - Investment: $investmentBalance, Main: $mainBalance');
          isLoading = false;
        });
      } catch (e2) {
        debugPrint('Error reopening box: $e2');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _saveBalances() {
    try {
      myBox?.put('investmentBalance', investmentBalance);
      myBox?.put('money', mainBalance);
      debugPrint('Saved - Investment: $investmentBalance, Main: $mainBalance');
    } catch (e) {
      debugPrint('Error saving balances: $e');
    }
  }

  void _showAddMoneyDialog() {
    debugPrint(
        'Current balances - Main: $mainBalance, Investment: $investmentBalance');

    if (mainBalance <= 0) {
      _showInsufficientFundsDialog();
      return;
    }

    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Money to Investments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Available in main account: €${mainBalance.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text(
                  'Current investment balance: €${investmentBalance.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount to add',
                  prefixText: '€',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String amountText = amountController.text.trim();
                double? amount = double.tryParse(amountText);

                debugPrint('Trying to parse amount: "$amountText" -> $amount');

                if (amount != null && amount > 0 && amount <= mainBalance) {
                  _transferMoney(amount);
                  Navigator.of(context).pop();
                } else {
                  debugPrint(
                      'Invalid amount: $amount, Main balance: $mainBalance');
                  _showInvalidAmountDialog();
                }
              },
              child: const Text('Add Money'),
            ),
          ],
        );
      },
    );
  }

  void _transferMoney(double amount) {
    setState(() {
      mainBalance -= amount;
      investmentBalance += amount;
    });
    _saveBalances();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('€${amount.toStringAsFixed(2)} added to investments'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insufficient Funds'),
          content: const Text(
              'You need money in your main account to add to investments.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showInvalidAmountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Amount'),
          content: const Text(
              'Please enter a valid amount that doesn\'t exceed your main account balance.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showWithdrawDialog() {
    if (investmentBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No funds available to withdraw'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw from Investments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Available to withdraw: €${investmentBalance.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount to withdraw',
                  prefixText: '€',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? amount = double.tryParse(amountController.text);
                if (amount != null &&
                    amount > 0 &&
                    amount <= investmentBalance) {
                  _withdrawMoney(amount);
                  Navigator.of(context).pop();
                } else {
                  _showInvalidAmountDialog();
                }
              },
              child: const Text('Withdraw'),
            ),
          ],
        );
      },
    );
  }

  void _withdrawMoney(double amount) {
    setState(() {
      investmentBalance -= amount;
      mainBalance += amount;
    });
    _saveBalances();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('€${amount.toStringAsFixed(2)} withdrawn to main account'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTopMoversWidget() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with arrow
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Top movers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Toggle buttons
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C1E),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showTopGainers = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: showTopGainers
                            ? const Color(0xFF444648)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'Top gainers',
                          style: TextStyle(
                            color:
                                showTopGainers ? Colors.white : Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showTopGainers = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !showTopGainers
                            ? const Color(0xFF444648)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'Top losers',
                          style: TextStyle(
                            color:
                                !showTopGainers ? Colors.white : Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stock grid - simplified approach
          Column(
            children: [
              // First row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < 4; i++)
                    _buildSimpleStockCard(
                      (showTopGainers ? topGainers : topLosers)[i]['symbol'],
                      (showTopGainers ? topGainers : topLosers)[i]
                          ['percentage'],
                      (showTopGainers ? topGainers : topLosers)[i]['color'],
                      isGainer: showTopGainers,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Second row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 4; i < 8; i++)
                    _buildSimpleStockCard(
                      (showTopGainers ? topGainers : topLosers)[i]['symbol'],
                      (showTopGainers ? topGainers : topLosers)[i]
                          ['percentage'],
                      (showTopGainers ? topGainers : topLosers)[i]['color'],
                      isGainer: showTopGainers,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top section with capital at risk
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Capital at risk',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '€${investmentBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '€0.00  0%',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.trending_up,
                            label: 'Trade',
                            onTap: () {},
                          ),
                          _buildActionButton(
                            icon: Icons.add,
                            label: 'Add money',
                            onTap: _showAddMoneyDialog,
                          ),
                          _buildActionButton(
                            icon: Icons.arrow_downward,
                            label: 'Withdraw',
                            onTap: _showWithdrawDialog,
                          ),
                          _buildActionButton(
                            icon: Icons.more_horiz,
                            label: 'More',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top Movers Widget
                _buildTopMoversWidget(),

                // Add some bottom spacing
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleStockCard(String symbol, String percentage, Color color,
      {bool isGainer = true}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                symbol.length > 3 ? symbol.substring(0, 3) : symbol,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            symbol,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 9,
              color: isGainer ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1E20),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: Colors.grey[400],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
