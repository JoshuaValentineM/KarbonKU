import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/view/tracking_page.dart';
import 'package:karbonku/view/profile_page.dart';
import 'package:karbonku/view/education_page.dart';
import 'package:karbonku/view/calculator_page.dart';
import 'package:karbonku/view/home_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final User? user;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    this.user,
  }) : super(key: key);

  void _navigateToPage(int index, BuildContext context) {
    Widget page;

    switch (index) {
      case 0:
        page = const TrackingPage();
        break;
      case 1:
        page = const CalculatorPage();
        break;
      case 2:
        page = const HomePage();
        break;
      case 3:
        page = EducationPage();
        break;
      case 4:
        if (user != null) {
          page = ProfilePage(user: user!);
        } else {
          page = const HomePage();
        }
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF3B645E),
      selectedItemColor: const Color(0xFF66D6A6),
      unselectedItemColor: const Color(0xFFFFFFFF),
      currentIndex: selectedIndex,
      onTap: (index) => _navigateToPage(index, context),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/trackIcon.png',
            width: 24,
            height: 24,
          ),
          label: 'Track',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/calculatorIcon.png',
            width: 24,
            height: 24,
          ),
          label: 'Calculator',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/homeIcon.png',
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/educationIcon.png',
            width: 24,
            height: 24,
          ),
          label: 'Education',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/img/profileIcon.png',
            width: 24,
            height: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
