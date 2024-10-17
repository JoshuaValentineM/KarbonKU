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

  double carbonReportPercentage = 149.0; // Ganti dengan nilai yang sesuai
  double totalCarbonEmitted = 8.2; // Ganti dengan nilai yang sesuai
  double totalDistanceTraveled = 48.0; // Ganti dengan nilai yang sesuai

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
              // Added Padding with top padding of 16
              Padding(
                padding:
                    const EdgeInsets.only(top: 32.0), // Padding atas sebesar 16
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.85, // 85% of screen width
                    height: 215, // Adjusting height to fit 3 rows
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A373B), Color(0xFF3B645E)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Padding inside container
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row for first line: 'Carbon Report' and 'Daily' box
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Carbon Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                width: 85,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Daily',
                                  style: TextStyle(
                                    color: Color(0xFF222222),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12), // Space between rows

                          // Row for second line: '149%', divider image, and new result text
                          Row(
                            children: [
                              Text(
                                '${carbonReportPercentage.toInt()}%',
                                style: TextStyle(
                                  color: Color(0xFFD66666),
                                  fontSize: 75,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Image.asset(
                                'assets/img/ReportDivider.png',
                                height: 100, // Adjust height as needed
                              ),
                              const SizedBox(width: 16),

                              // Column to replace 'hasil' with two rows of text and images
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // Align to start
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${totalCarbonEmitted.toString()}kg',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                          width:
                                              20), // Space between text and image
                                      Image.asset(
                                        'assets/img/leaf.png',
                                        height: 14, // Adjust height as needed
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: 4), // Space between rows
                                  Row(
                                    children: [
                                      Text(
                                        '${totalDistanceTraveled.toString()}km',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                          width:
                                              4), // Space between text and image
                                      Image.asset(
                                        'assets/img/pin_range.png',
                                        height: 16, // Adjust height as needed
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12), // Space between rows

                          // Third line: Small note text and circles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                '*berdasarkan Maximum Carbon Standard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),

                              const SizedBox(
                                  width: 22), // Space between text and circles

                              // Generate circles
                              Row(
                                children: List.generate(4, (index) {
                                  // Determine color based on index
                                  Color circleColor =
                                      index == 0 ? Colors.white : Colors.grey;
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(
                                        right: 4), // Space between circles
                                    decoration: BoxDecoration(
                                      color: circleColor,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height:
                      16.0), // Add some space between the container and the next widget
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
