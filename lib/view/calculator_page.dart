import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karbonku/model/Vehicle.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseAuth auth = FirebaseAuth.instance;
  double carbonTaxRate = 30; // Tarif pajak karbon per kilogram CO2e

  List<Map<String, dynamic>> vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  // Function to load vehicle data from Firestore
  Future<void> _loadVehicleData() async {
    final vehiclesRef = FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: auth.currentUser!.uid);
    final querySnapshot = await vehiclesRef.get();

    List<Map<String, dynamic>> tempVehicles = [];

    for (var doc in querySnapshot.docs) {
      var vehicleData = doc.data() as Map<String, dynamic>;
      print("Data Kendaraan: $vehicleData"); // Log data kendaraan

      if (vehicleData.containsKey('tracks')) {
        var tracks = vehicleData['tracks'] as List<dynamic>;

        // Filter tracks by year
        var filteredTracks = tracks.where((track) {
          var trackDate;

          // Handle both Timestamp and String formats
          if (track['date'] is Timestamp) {
            trackDate = (track['date'] as Timestamp).toDate();
          } else if (track['date'] is String) {
            trackDate = DateTime.tryParse(track['date']);
          }

          // Filter by the current year
          return trackDate != null && trackDate.year == currentYear;
        }).toList();

        if (filteredTracks.isNotEmpty) {
          tempVehicles.add({
            'vehicleName': vehicleData['vehicleName'],
            'vehicleType': vehicleData['vehicleType'],
            'tracks': filteredTracks,
          });
        }
      } else {
        print("Tidak ada 'tracks' dalam dokumen ${doc.id}");
      }
    }

    setState(() {
      vehicles = tempVehicles;
    });

    print(
        'Total Pajak Karbon: Rp ${calculateTotalTax().toStringAsFixed(2)}'); // Hitung total pajak setelah data terisi
  }

  double calculateTotalTax() {
    double totalTax = 0;
    for (var vehicle in vehicles) {
      for (var track in vehicle['tracks']) {
        print(
            'Track Carbon Emission: ${track['carbon_emission']}'); // Log tambahan
        totalTax += (track['carbon_emission'] / 1000) * carbonTaxRate;
      }
    }
    print('Total Carbon Tax: $totalTax'); // Log total pajak karbon
    return totalTax;
  }

  void incrementYear() {
    setState(() {
      currentYear++;
      _loadVehicleData();
    });
  }

  void decrementYear() {
    setState(() {
      currentYear--;
      _loadVehicleData();
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // First box: Year with arrows on left and right
            const SizedBox(height: 24),
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
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header row for first and second columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Penghitungan Pajak',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Image.asset(
                            'assets/img/Leaf_fill.png',
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (vehicles.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 112.0),
                            child: Text(
                              'Belum ada data untuk tahun ini.',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            // Menampilkan data kendaraan terlebih dahulu
                            ...vehicles.map((vehicle) {
                              double totalEmissions = 0;

                              // Menghitung total emisi dari tracks
                              vehicle['tracks'].forEach((track) {
                                totalEmissions += track['carbon_emission'];
                              });

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          vehicle['vehicleType'] == 'motor'
                                              ? 'assets/img/MotorbikeIconFill.png'
                                              : 'assets/img/CarIconFill.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          vehicle['vehicleName'],
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(totalEmissions / 1000).toStringAsFixed(2)} kg', // Convert to kg
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              );
                            }).toList(),

                            // Tarif Pajak Karbon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Tarif Pajak Karbon',
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 16),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _showWarningBottomSheet,
                                  child: Image.asset(
                                    'assets/img/informationIcon.png',
                                    width: 14,
                                    height: 14,
                                  ),
                                ),
                                Spacer(),
                                SizedBox(width: 8),
                                Text(
                                  'Rp${carbonTaxRate.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
// Menampilkan Pajak per kendaraan setelah Tarif Pajak Karbon
                            ...vehicles.map((vehicle) {
                              double totalEmissions = 0;

                              // Menghitung total emisi dari tracks
                              vehicle['tracks'].forEach((track) {
                                totalEmissions += track['carbon_emission'];
                              });

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pajak ${vehicle['vehicleName']}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rp${((totalEmissions / 1000) * carbonTaxRate).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 8),

                            // Menampilkan Total Pajak Karbon di bagian bawah daftar kendaraan
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                    ]),
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
