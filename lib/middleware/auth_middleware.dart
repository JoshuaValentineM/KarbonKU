import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMiddleware {
  static Future<void> checkAuthentication(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }
}