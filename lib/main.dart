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
    initialRoute:
        isFirstLaunch ? '/onboarding' : (user == null ? '/auth' : '/home'),
  ));
}

Future<bool> _isFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

  if (isFirstLaunch == null || isFirstLaunch == true) {
    prefs.setBool('isFirstLaunch', false);
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
          return ProfilePage(user: user!);
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
      backgroundColor: const Color(0xFFEFFFF8),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildPage(
            'assets/img/HeaderWelcome#1.png',
            'assets/img/WelcomeIcon#1.png',
            260,
            353,
            'Selamat Datang!',
            'KarbonKU adalah aplikasi karya anak bangsa yang ditujukan untuk membantu mengurangi emisi karbon di Indonesia melalui penerapan pajak karbon.',
          ),
          _buildPage(
            'assets/img/HeaderWelcome#2.png',
            'assets/img/WelcomeIcon#2.png',
            172,
            353,
            'Carbon Emission Tracking',
            'Pantau karbon yang dihasilkan kendaraan kamu secara akurat berdasarkan jenis dan kondisinya!',
          ),
          _buildPage(
            'assets/img/HeaderWelcome#3.png',
            'assets/img/WelcomeIcon#3.png',
            172,
            353,
            'Tax Carbon Calculator',
            'Hitung perkiraan biaya pajak karbon yang harus dibayarkan berdasarkan emisi yang telah dihasilkan!',
          ),
          _buildPage(
            'assets/img/HeaderWelcome#4.png',
            'assets/img/WelcomeIcon#4.png',
            172,
            353,
            'Education Corner',
            'Dapatkan informasi terbaru seputar pajak karbon dan kondisi emisi karbon di Indonesia maupun global!',
          ),
        ],
      ),
      bottomSheet: _buildBottomNavigation(),
    );
  }

  Widget _buildPage(String headerImagePath, String imagePath,
      double imageHeight, double imageWidth, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header image container
        Container(
          color: const Color(
              0xFFEFFFF8), // Bisa disesuaikan jika ada warna background
          child: Image.asset(
            headerImagePath,
            width: double.infinity, // Memenuhi lebar layar
            fit: BoxFit.cover, // Menyesuaikan proporsi gambar
          ),
        ),
        // ImagePath container
        Container(
          color: const Color(0xFFEFFFF8), // Warna latar belakang
          alignment: Alignment.center, // Menempatkan gambar di tengah
          padding: EdgeInsets.only(
              left: 8, right: 8, top: _currentPage == 0 ? 20 : 100),
          child: Image.asset(
            imagePath,
            height: imageHeight,
            width: imageWidth,
            fit: BoxFit.contain, // Sesuaikan agar gambar tetap proporsional
          ),
        ),
        // Text container
        const SizedBox(height: 40),
        Container(
          color: const Color(0xFFEFFFF8), // Warna latar belakang
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      color: const Color(0xFFEFFFF8),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Posisikan indikator di kiri
        children: [
          // Menambahkan indikator halaman menggunakan gambar
          Row(
            children: List.generate(4, (index) {
              String imagePath = (_currentPage == index)
                  ? 'assets/img/LeafCurrentPage.png' // Gambar untuk halaman aktif
                  : 'assets/img/LeafPage.png'; // Gambar untuk halaman lainnya
              return Container(
                margin:
                    const EdgeInsets.only(right: 2), // Jarak antar indikator
                child: Image.asset(
                  imagePath,
                  width: 23, // Sesuaikan ukuran gambar
                  height: 35, // Sesuaikan ukuran gambar
                ),
              );
            }),
          ),
          const Spacer(), // Memberikan ruang kosong di tengah agar tombol di sebelah kanan
          if (_currentPage >= 0 && _currentPage != 3)
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text(
                'LEWATI',
                style: TextStyle(
                  color: Color(0xFF757B7B),
                ),
              ),
            ),
          const SizedBox(width: 10),
          _currentPage < 3
              ? ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF66D6A6), // Background color
                  ),
                  child: const Text(
                    'LANJUT',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF66D6A6), // Background color
                  ),
                  child: const Text(
                    'SELESAI',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
