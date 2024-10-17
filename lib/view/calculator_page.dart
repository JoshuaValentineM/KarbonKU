import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karbonku/model/Vehicle.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'education_page.dart';
import 'tracking_page.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 1;
  int currentYear = DateTime.now().year; // Current year

  double carbonTaxRate = 30; // Tarif pajak karbon per kilogram CO2e

  // Data kendaraan dummy
  List<Vehicle> vehicles = [
    Vehicle(
        vehicleType: 'Motor', vehicleName: 'Honda Beat', vehicleEmission: 600),
    Vehicle(
        vehicleType: 'Mobil',
        vehicleName: 'Toyota Creta',
        vehicleEmission: 1000),
  ];

  double calculateTotalTax() {
    double totalTax = 0;
    for (var vehicle in vehicles) {
      totalTax += vehicle.vehicleEmission * carbonTaxRate;
    }
    return totalTax;
  }

  void incrementYear() {
    setState(() {
      currentYear++;
    });
  }

  void decrementYear() {
    setState(() {
      currentYear--;
    });
  }

  void _showWarningBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.35,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "UU Nomor 7 Tahun 2021",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8), // Space between text and image
                  Image.asset(
                    'assets/img/informationIcon.png', // Path to informationIcon.png
                    width: 14,
                    height: 14,
                  ),
                ],
              ),
              const SizedBox(height: 8), // Space between text and divider
              const Divider(), // Divider line
              const SizedBox(height: 8), // Space after the divider
              const Text(
                "Tarif pajak karbon ditetapkan lebih tinggi atau sama dengan harga karbon di pasar karbon per kilogram karbon dioksida ekuivalen (CO2e) atau satuan yang setara (Rp30,00).",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
              const Spacer(),
              const Text(
                "BAB VI Pasal 13 ayat (8) dan (9)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Spacer(), // To push the button to the bottom
              Center(
                child: SizedBox(
                  width: double.infinity, // Make button full width
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF66D6A6), // Background color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Button height
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Border radius
                      ),
                    ),
                    child: const Text(
                      "Mengerti",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
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
    final double width =
        MediaQuery.of(context).size.width * 0.85; // 85% of screen width

    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B645E),
        elevation: 0,
        title: const Text(
          'Calculator',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First box: Year with arrows on left and right
            Center(
              child: Container(
                width: width, // Using 85% of the screen width
                height: 54, // Height of the box
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A373B), Color(0xFF3B645E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left arrow "<" using TextButton
                    TextButton(
                      onPressed: decrementYear,
                      child: const Text(
                        '<',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Year text in the middle
                    Expanded(
                      child: Center(
                        child: Text(
                          currentYear.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Right arrow ">" using TextButton
                    TextButton(
                      onPressed: incrementYear,
                      child: const Text(
                        '>',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            // Second box: Tax calculation column and leaf icon
            Container(
              width: width,
              height: MediaQuery.of(context).size.height * 0.45,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row for first and second columns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Text "Penghitungan Pajak"
                      const Text(
                        'Penghitungan Pajak',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Leaf icon
                      Image.asset(
                        'assets/img/Leaf_fill.png', // Make sure Leaf_fill.png is in assets
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Space after header

                  // Loop through vehicles to display dynamic data
                  for (var vehicle in vehicles) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          vehicle.vehicleType == 'Motor'
                              ? 'assets/img/MotorbikeIconFill.png'
                              : 'assets/img/CarIconFill.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          vehicle.vehicleName,
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 16),
                        ),
                        const Spacer(),
                        const SizedBox(width: 8), // Space before the weight
                        Text(
                          '${vehicle.vehicleEmission}kg',
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Space between each row
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Tarif Pajak Karbon',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap:
                            _showWarningBottomSheet, // Call the method on tap
                        child: Image.asset(
                          'assets/img/informationIcon.png', // Ensure the image is in the assets
                          width: 14,
                          height: 14,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 8), // Space before the weight
                      Text(
                        'Rp${carbonTaxRate.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Space after header

                  // Pajak per kendaraan
                  for (var vehicle in vehicles) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Pajak ${vehicle.vehicleName}',
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 16),
                        ),
                        const Spacer(),
                        const SizedBox(width: 8), // Space before the weight
                        Text(
                          'Rp${(vehicle.vehicleEmission * carbonTaxRate).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Space after each row
                  ],

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Space after header

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Rp${calculateTotalTax().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF66D6A6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0),
            // Small text below the box with the same width
            Container(
              width: width, // Using the same width as the box above
              child: const Text(
                '*Biaya pajak karbon berdasarkan pada laporan karbon dan peraturan yang berlaku.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A373B),
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        user: user,
      ),
    );
  }
}
