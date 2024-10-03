import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/view/tracking_page.dart';
import '../middleware/auth_middleware.dart';
import 'profile_page.dart';
import 'education_page.dart';
import 'calculator_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Track the selected tab index
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
        page = EducationPage();
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
        reverseTransitionDuration:
            Duration.zero, // No reverse transition duration
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(15),
          height: 700, // Adjust height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Done button to close the bottom sheet
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context), // Close the bottom sheet
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Color(0xFF1A373B), // Color for the Done text
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5), // Add some space
              // Image of carbon_standard
              Center(
                child: Image.asset(
                  'assets/img/carbon_standard_2.png', // Your image asset
                  width: 370,
                  height: 227, // Adjust the height as needed
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 5), // Add some space
              // Description text
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Berdasarkan ",
                      style: TextStyle(fontSize: 10),
                    ),
                    TextSpan(
                      text: "research ",
                      style: TextStyle(
                          fontSize: 10,
                          fontStyle:
                              FontStyle.italic), // Italic style for "research"
                    ),
                    TextSpan(
                      text:
                          "dari The Nature Conservancy (2020) untuk menghindari kenaikan suhu global 2°C pada 2050.",
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5), // Add some space for the table
              // Table with specified contents
              Table(
                // Remove borders by not specifying a border
                children: [
                  // Header row
                  TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(2), // Reduced padding
                          child: Text(""), // Empty cell for (1,1)
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(2), // Reduced padding
                          child: Image.asset('assets/img/daun.png',
                              width: 20, height: 20), // Adjust size
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(2), // Reduced padding
                          child: Image.asset('assets/img/daun.png',
                              width: 20, height: 20), // Adjust size
                        ),
                      ),
                    ],
                  ),

                  // Row 2
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "Harian",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "21.92 - 32.88 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "5.48 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row 3
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "Mingguan",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "153.44 - 230.16 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "38.36 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row 4
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "Bulanan",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "613.76 - 920.64 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "153.44 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row 5
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "Tahunan",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "8,076.8 - 12,115.2 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "2019.2 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 13, // Adjusted font size
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "* Data yang disajikan hanya perkiraan",
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom info box with border radius, image, and bottom sheet trigger
            // Custom info box with border radius, image, and bottom sheet trigger
            GestureDetector(
              onTap: () =>
                  _showBottomSheet(context), // Show bottom sheet on tap
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Image with opacity
                      Image.asset(
                        'assets/img/carbon_standard.png',
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.darken,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Persistent BottomNavigationBar for switching between pages
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Ensures that background color stays solid
        backgroundColor: const Color(0xFF3B645E), // Set background color
        selectedItemColor:
            const Color(0xFF66D6A6), // Set color for selected label and icon
        unselectedItemColor: const Color(
            0xFFFFFFFF), // Set color for unselected labels and icons
        currentIndex: _selectedIndex, // Set the selected tab
        onTap:
            _onItemTapped, // Handle tab changes and navigate to relevant page
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
