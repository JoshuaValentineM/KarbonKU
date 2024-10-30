import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import '../middleware/auth_middleware.dart';
import 'carbon_report_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Default selected tab is Home
  User? user;
  bool isLoading = false;

  final PageController _pageController = PageController();
  double carbonReportPercentage = 149.0; // Ganti dengan nilai yang sesuai
  double totalCarbonEmitted = 8.2; // Ganti dengan nilai yang sesuai
  double totalDistanceTraveled = 48.0; // Ganti dengan nilai yang sesuai

  List<String> cityList = [];
  String? selectedCity;
  List<Map<String, dynamic>> emissionLocations = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
    fetchCities(); // Panggil fungsi untuk mengambil kota
  }

  Future<Position> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchCities() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('test_emission_locations')
          .get();
      setState(() {
        cityList = querySnapshot.docs.map((doc) => doc.id).toList();
        selectedCity = cityList.isNotEmpty ? cityList[0] : null;
      });

      // Fetch workshops for the first city
      if (selectedCity != null) {
        await fetchWorkshops(selectedCity!);
      }
    } catch (e) {
      // Handle any errors
      print("Error fetching cities: $e");
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false after fetching
      });
    }
  }

  Future<void> fetchWorkshops(String city) async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    try {
      Position userPosition = await _getUserLocation();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('test_emission_locations')
          .doc(city)
          .collection('workshops')
          .get();

      // Calculate distance for each workshop
      setState(() {
        emissionLocations = querySnapshot.docs.map((doc) {
          final workshopLatitude = double.tryParse(doc['latitude']);
          final workshopLongitude = double.tryParse(doc['longitude']);

          if (workshopLatitude != null && workshopLongitude != null) {
            double distance = Geolocator.distanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              workshopLatitude,
              workshopLongitude,
            );

            return {
              'name': doc['name'],
              'address': doc['address'],
              'distance': distance / 1000,
              'openTime': doc['openTime'],
              'closeTime': doc['closeTime'],
            };
          } else {
            return {
              'name': doc['name'],
              'address': doc['address'],
              'distance': 0.0,
              'openTime': doc['openTime'],
              'closeTime': doc['closeTime'],
            };
          }
        }).toList();
      });
    } catch (e) {
      // Handle any errors
      print("Error fetching workshops: $e");
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false after fetching
      });
    }
  }

  void _showCarbonStandardPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(15),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width *
                  1, // Atur lebar maksimal popup sesuai kebutuhan
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image of carbon_standard
                  Center(
                    child: Image.asset(
                      'assets/img/carbon_standard_2.png', // Your image asset
                      width:
                          600, // Menyesuaikan ukuran gambar agar tidak nabrak sisi
                      fit: BoxFit.contain,
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
                              fontStyle: FontStyle
                                  .italic), // Italic style for "research"
                        ),
                        TextSpan(
                          text:
                              "dari The Nature Conservancy (2020) untuk menghindari kenaikan suhu global 2°C pada 2050.",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15), // Add space for the table
                  // Table with specified contents
                  Table(
                    children: [
                      TableRow(
                        children: [
                          TableCell(child: Text("")),
                          TableCell(
                            child: Image.asset(
                              'assets/img/jarak.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                          TableCell(
                            child: Image.asset(
                              'assets/img/daun.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Harian",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "21.92 - 32.88 km",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "5.48 kg",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Mingguan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "153.44 - 230.16 km",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "38.36 kg",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Bulanan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "613.76 - 920.64 km",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "153.44 kg",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Tahunan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "8,076.8 - 12,115.2 km",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "2019.2 kg",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF66D6A6), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    "* Data yang disajikan hanya perkiraan",
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEmissionTestPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateWorkshops(String city) async {
              // Set loading state to true before fetching workshops
              setState(() {
                isLoading = true;
              });

              await fetchWorkshops(city); // Call fetchWorkshops directly

              // After fetching, set loading to false again
              setState(() {
                isLoading = false;
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(16),
                height: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/img/maps.png',
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Pilih Kota",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        hint:
                            Text("Pilih Kota", style: TextStyle(fontSize: 12)),
                        value: selectedCity,
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != selectedCity) {
                            setState(() {
                              selectedCity = newValue;
                            });
                            updateWorkshops(
                                selectedCity!); // Call to update workshops
                          }
                        },
                        isExpanded: true,
                        underline: SizedBox(),
                        items: cityList.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(
                              city,
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Show loading spinner if isLoading is true
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: emissionLocations.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emissionLocations[index]['name']
                                              as String,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          emissionLocations[index]['address']
                                              as String,
                                        ),
                                        Text(
                                          "${emissionLocations[index]['distance'].toStringAsFixed(2)} km", // Format distance to two decimal places
                                        ),
                                        Text(
                                          "Open ${emissionLocations[index]['openTime']} - ${emissionLocations[index]['closeTime']} everyday",
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "${emissionLocations[index]['distance'].toStringAsFixed(2)} km", // Format distance to two decimal places
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context); // Middleware auth

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
            const SizedBox(height: 32), // Jarak lebih besar di bagian atas
            SizedBox(
              height: 225, // Atur tinggi untuk PageView
              child: PageView(
                controller: _pageController,
                children: [
                  CarbonReportView(
                    carbonReportPercentage: carbonReportPercentage,
                    totalCarbonEmitted: totalCarbonEmitted,
                    totalDistanceTraveled: totalDistanceTraveled,
                    reportType: 'Daily',
                    currentPage: 0,
                  ),
                  CarbonReportView(
                    carbonReportPercentage: carbonReportPercentage - 10,
                    totalCarbonEmitted: totalCarbonEmitted * 2,
                    totalDistanceTraveled: totalDistanceTraveled * 3,
                    reportType: 'Weekly',
                    currentPage: 1,
                  ),
                  CarbonReportView(
                    carbonReportPercentage: carbonReportPercentage - 40,
                    totalCarbonEmitted: totalCarbonEmitted * 2,
                    totalDistanceTraveled: totalDistanceTraveled * 3,
                    reportType: 'Monthly',
                    currentPage: 2,
                  ),
                  CarbonReportView(
                    carbonReportPercentage: carbonReportPercentage - 60,
                    totalCarbonEmitted: totalCarbonEmitted * 2,
                    totalDistanceTraveled: totalDistanceTraveled * 3,
                    reportType: 'Yearly',
                    currentPage: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32), // Jarak antar widget yang lebih besar
            GestureDetector(
              onTap: () => _showCarbonStandardPopup(context),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 215, // Matching the height of Carbon Report widget
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: const DecorationImage(
                      image: AssetImage('assets/img/carbon_standard_fix.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 10), // Larger shadow at the bottom
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "MAXIMUM",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36, // Adjusted size for MAXIMUM
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "CARBON STANDARD",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        20, // Smaller size for CARBON STANDARD
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16), // Space between text and icon
                            Image.asset(
                              'assets/img/icon_maximum_carbon_standard.png',
                              width: 80, // Adjust size as needed
                              height: 80, // Adjust size as needed
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32), // Jarak antar widget yang lebih besar
            GestureDetector(
              onTap: () => _showEmissionTestPopup(context),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 215, // Matching the height of Carbon Report widget
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: const DecorationImage(
                      image: AssetImage('assets/img/lokasiujiemisi.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 10), // Shadow lebih besar di bawah
                      ),
                    ],
                  ),
                  child: Stack(
                    // Menggunakan Stack untuk lapisan
                    children: [
                      // Layer gelap pertama
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3), // Gelap 30%
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      // Layer gelap kedua yang lebih gelap
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5), // Gelap 50%
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(20.0),
                            ),
                          ),
                          padding: EdgeInsets.all(16), // Padding untuk teks
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lokasi Uji Emisi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28, // Perbesar ukuran font
                                  fontWeight: FontWeight
                                      .w600, // Set ketebalan font sama
                                ),
                              ),
                              SizedBox(height: 4), // Spasi antara teks
                              Row(
                                children: [
                                  Text(
                                    "Terdekat",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28, // Samakan ukuran font
                                      fontWeight:
                                          FontWeight.w600, // Samakan ketebalan
                                    ),
                                  ),
                                  SizedBox(
                                      width: 8), // Jarak antara teks dan ikon
                                  Icon(
                                    Icons.arrow_forward, // Ikon panah ke kanan
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32), // Jarak lebih besar di bagian bawah
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
