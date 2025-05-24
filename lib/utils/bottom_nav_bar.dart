// ignore_for_file: file_names, prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hackaton_sheepai_2025/pages/ChooseInvestmentPage/choose_investment_page.dart';
import 'package:hackaton_sheepai_2025/pages/home/home_page.dart';
import 'package:hackaton_sheepai_2025/pages/paymentsPage/payments_page.dart';
import 'package:hackaton_sheepai_2025/pages/productsPage/products_page.dart';
import 'package:hackaton_sheepai_2025/pages/settings/settings_page.dart';
import 'package:hackaton_sheepai_2025/pages/stocks/stocks_page.dart';

// Define your pages here - you'll need to add the missing pages
final List<Widget> _pages = [
  HomePage(), // Početna
  PaymentsPage(),
  ChooseInvestmentPage(), // Investiranje
  ProductsPage(),
  StocksPage(), // Više
];

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _page = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Color(0xFF1D1E20),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Početna (Home)
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Početna',
                index: 0,
              ),
              // Plaćanja (Payments)
              _buildNavItem(
                icon: Icons.credit_card_outlined,
                label: 'Plaćanja',
                index: 1,
              ),
              // Investiranje (Investment)
              _buildNavItem(
                icon: Icons.trending_up_outlined,
                label: 'Investiranje',
                index: 2,
              ),
              // Proizvodi (Products)
              _buildNavItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Proizvodi',
                index: 3,
              ),
              // Više (More)
              _buildNavItem(
                icon: Icons.menu,
                label: 'Više',
                index: 4,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: Center(
          child: PageView(
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _page = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _page == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _page = index;
        });
        _pageController.jumpToPage(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Color(0xFF52AE30) : Colors.grey[400],
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Color(0xFF52AE30) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
