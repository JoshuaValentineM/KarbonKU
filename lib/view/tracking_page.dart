import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
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

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context);

    return Scaffold(
      body: Center(
          child: Text(
              'Tracking Page Content')), // Placeholder for the default content

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        user: user,
      ),
    );
  }
}
