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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? user = FirebaseAuth.instance.currentUser;

  // Mengecek apakah onboarding sudah ditampilkan sebelumnya
  bool isFirstLaunch = await _isFirstLaunch();

  runApp(MyApp(
    initialRoute: isFirstLaunch ? '/onboarding' : (user == null ? '/auth' : '/home'),
  ));
}

Future<bool> _isFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
  
  if (isFirstLaunch == null || isFirstLaunch == true) {
    prefs.setBool('isFirstLaunch', false); // Set ke false setelah pertama kali dibuka
    return true;
  }
  return false;
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
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildPage(
            'assets/img/selamat_datang.png',
            'Selamat Datang!',
            'KarbonKU adalah aplikasi karya anak bangsa yang ditujukan untuk membantu mengurangi emisi karbon di Indonesia melalui penerapan pajak karbon.',
          ),
          _buildPage(
            'assets/img/mobilcarbontrack.png',
            'Carbon Emission Tracking',
            'Pantau karbon yang dihasilkan kendaraan kamu secara akurat berdasarkan jenis dan kondisinya!',
          ),
          _buildPage(
            'assets/img/taxcarboncalculator.png',
            'Tax Carbon Calculator',
            'Hitung perkiraan biaya pajak karbon yang harus dibayarkan berdasarkan emisi yang telah dihasilkan!',
          ),
          _buildPage(
            'assets/img/educationcorner.png',
            'Education Corner',
            'Dapatkan informasi terbaru seputar pajak karbon dan kondisi emisi karbon di Indonesia maupun global!',
          ),
        ],
      ),
      bottomSheet: _buildBottomNavigation(),
    );
  }

  Widget _buildPage(String imagePath, String title, String body) {
  return Container(
    color: const Color(0xFFEFFFF8), // Background page color
    padding: const EdgeInsets.symmetric(horizontal: 16), // Menambahkan padding pada container
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start, // Menyelaraskan elemen ke kiri
      children: [
        Align(
          alignment: Alignment.center, // Menyelaraskan gambar di tengah
          child: Image.asset(
            imagePath,
            height: 200, // Sesuaikan dengan ukuran gambar yang diinginkan
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 8), // Padding untuk menggeser title ke kiri
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left, // Rata kiri
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 8), // Padding yang sama untuk body
          child: Text(
            body,
            textAlign: TextAlign.justify, // Rata kiri-kanan
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildBottomNavigation() {
    return Container(
      color: const Color(0xFFEFFFF8), // Menyamakan warna dengan latar belakang halaman
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: const Text('Back'),
            ),
          _currentPage < 3
              ? TextButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: const Text('Next'),
                )
              : ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman utama setelah onboarding selesai
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: const Text('Get Started'),
                ),
        ],
      ),
    );
  }
}
