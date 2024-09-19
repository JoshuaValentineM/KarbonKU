import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B645E),
        elevation: 0,
        title: const Text(
          'Calculator',
          style: TextStyle(color: Colors.white),
        ) // Warna latar belakang AppBar
      ),
      body: Center(
        child: Text(
          'Calculator Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}