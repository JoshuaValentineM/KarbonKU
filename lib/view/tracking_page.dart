import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../middleware/auth_middleware.dart';
import 'profile_page.dart';
import 'education_page.dart';
import 'calculator_page.dart';
import 'home_page.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  _TrackingPage createState() => _TrackingPage();
}

class _TrackingPage extends State<TrackingPage> {
  int _selectedIndex = 0; // Track the selected tab index
  User? user; // Declare a variable to store the Firebase user

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
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
      _selectedIndex = index; // Update selected index
      _navigateToPage(index); // Call navigation function
    });
  }

// Navigate to the respective page based on the index without any transition
void _navigateToPage(int index) {
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
      page =  EducationPage();
      break;
    case 4:
      page = ProfilePage(user: user!);
      break;
    default:
      page = const HomePage();
  }

  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero, // No transition duration
      reverseTransitionDuration: Duration.zero, // No reverse transition duration
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context);

    return Scaffold(
      body: Center(child: Text('Tracking Page Content')), // Placeholder for the default content

      // Persistent BottomNavigationBar for switching between pages
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures that background color stays solid
        backgroundColor: const Color(0xFF3B645E), // Set background color
        selectedItemColor: const Color(0xFF66D6A6), // Set color for selected label and icon
        unselectedItemColor: const Color(0xFFFFFFFF), // Set color for unselected labels and icons
        currentIndex: _selectedIndex, // Set the selected tab
        onTap: _onItemTapped, // Handle tab changes and navigate to relevant page
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Tracking',
          ),
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
