import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/view/calculator_page.dart';
import 'view/auth_page.dart';
import 'view/home_page.dart';
import 'view/profile_page.dart';
import 'view/education_page.dart';
import 'firebase_options.dart';
import 'view/tracking_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(
    initialRoute: user == null ? '/auth' : '/home',
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KarbonKU',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28.0,
            fontWeight: FontWeight.w500,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24.0,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22.0,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.0,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.0,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.0,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.0,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.0,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.0,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.0,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.0,
          ),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) {
          final User? user =
              ModalRoute.of(context)?.settings.arguments as User?;
          return ProfilePage(user: user!); // Ensure `user` is not null
        },
        '/education': (context) => EducationPage(),
        '/calculator': (context) => CalculatorPage(),
        '/tracking': (context) => TrackingPage(),
      },
    );
  }
}
