import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../middleware/auth_middleware.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to Home Page!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: user, // Pass user as argument
                );
              },
              child: const Text('Profile'),
            ),
            ElevatedButton(
              onPressed: () => _signOut(context),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 20),
            // Tambahkan button untuk EducationPage
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/education');
              },
              child: const Text('Go to Education Page'),
            ),
          ],
        ),
      ),
    );
  }
}
