// ignore_for_file: file_names, prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:hackaton_sheepai_2025/pages/home/home_page.dart';
import 'package:hackaton_sheepai_2025/pages/settings/settings_page.dart';

// Define your pages here
final List<Widget> _pages = [
  HomePage(),
  HomePage(),
  SettingsPage(),
];

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        animationCurve: standardEasing,
        color: Color.fromARGB(255, 181, 139, 233),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        key: _bottomNavigationKey,
        items: <Widget>[
          Icon(Icons.home,
              size: 35,
              color: _page == 0
                  ? Color.fromARGB(255, 255, 255, 255)
                  : Colors.white),
          Icon(Icons.photo_camera,
              size: 35,
              color: _page == 1
                  ? Color.fromARGB(255, 255, 255, 255)
                  : Colors.white),
          Icon(Icons.settings,
              size: 35,
              color: _page == 2
                  ? Color.fromARGB(255, 255, 255, 255)
                  : Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
          // Use the controller to change pages
          _pageController.jumpToPage(index);
        },
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
}
