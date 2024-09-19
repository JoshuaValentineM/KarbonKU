import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../middleware/auth_middleware.dart';
import 'package:karbonku/view/profile_page.dart';
import 'package:karbonku/view/education_page.dart';
import 'calculator_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track the selected tab index
  User? user; // Declare a variable to store the Firebase user

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
  }

  // Pages to display based on the selected tab
  List<Widget> _pages() {
    return [
      CalculatorPage(), // Calculator page
      Center(child: Text('Home Page Content')), // Home page content
      EducationPage(), // Custom widget for Education page
      ProfilePage(user: user!), // Custom widget for Profile page with user parameter
    ];
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/auth',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Sign-Out error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Switch pages based on tab index
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context);

    return Scaffold(
      body: _pages()[_selectedIndex], // Display the selected page content

      // Persistent BottomNavigationBar for switching between pages
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures that background color stays solid
        backgroundColor: const Color(0xFF3B645E), // Set background color
        selectedItemColor: const Color(0xFF66D6A6), // Set color for selected label and icon
        unselectedItemColor: const Color(0xFFFFFFFF), // Set color for unselected labels and icons
        currentIndex: _selectedIndex, // Set the selected tab
        onTap: _onItemTapped, // Handle tab changes and display relevant page
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Education',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
