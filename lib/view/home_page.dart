import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import '../middleware/auth_middleware.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Default selected tab is Home
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
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
              SizedBox(height: 15), // Add some space for the table
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
                          child: Image.asset('assets/img/jarak.png',
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
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "Harian",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "21.92 - 32.88 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "5.48 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row 3
                  TableRow(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "Mingguan",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "153.44 - 230.16 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "38.36 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row 4
                  TableRow(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "Bulanan",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "613.76 - 920.64 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "153.44 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row 5
                  TableRow(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "Tahunan",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "8,076.8 - 12,115.2 km",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Text(
                          "2019.2 kg",
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            color: Color(0xFF66D6A6),
                            fontSize: 12, // Adjusted font size
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

    return Scaffold(
        backgroundColor: const Color(0xFFEFFFF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3B645E),
          elevation: 0,
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          user: user,
        ));
  }
}
