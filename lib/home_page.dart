import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the AuthPage after sign-out
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      // Handle sign-out error
      print('Sign-Out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _signOut(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
