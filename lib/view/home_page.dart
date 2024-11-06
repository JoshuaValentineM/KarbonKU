import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/model/Vehicle.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import '../middleware/auth_middleware.dart';
import 'carbon_report_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  List<Vehicle> vehicles = [
    Vehicle(
        vehicleType: 'Motor',
        vehicleName: 'Honda Beat',
        vehicleEmission: 3,
        vehicleTravel: 20),
    Vehicle(
        vehicleType: 'Mobil',
        vehicleName: 'Creta',
        vehicleEmission: 5,
        vehicleTravel: 24),
    Vehicle(
        vehicleType: 'Mobil',
        vehicleName: 'Inova',
        vehicleEmission: 3,
        vehicleTravel: 54),
  ];

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
              'latitude':
                  workshopLatitude.toString(), // Ensure latitude is included
              'longitude':
                  workshopLongitude.toString(), // Ensure longitude is included
              'distance': distance / 1000,
              'openTime': doc['openTime'],
              'closeTime': doc['closeTime'],
            };
          } else {
            return {
              'name': doc['name'],
              'address': doc['address'],
              'latitude': null,
              'longitude': null,
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

  late GoogleMapController mapController;

  // Function to set the map controller once the map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showEmissionTestPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateWorkshops(String city) async {
              try {
                setState(() {
                  isLoading = true;
                });

                await fetchWorkshops(city);
                print("emissionLocations: $emissionLocations");
                // Move the camera to the first workshop location if available
                if (emissionLocations.isNotEmpty) {
                  double? lat =
                      double.tryParse(emissionLocations[0]['latitude'] ?? '');
                  double? lng =
                      double.tryParse(emissionLocations[0]['longitude'] ?? '');

                  if (lat != null && lng != null) {
                    mapController.animateCamera(
                      CameraUpdate.newLatLng(LatLng(lat, lng)),
                    );
                  }
                }

                setState(() {
                  isLoading = false;
                });
              } catch (error) {
                setState(() {
                  isLoading = false;
                });
                print("Error fetching workshops: $error");
              }
            }

            // Set initial location for the map
            LatLng initialLocation = LatLng(-6.200000, 106.816666);

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
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: initialLocation,
                              zoom: 11,
                            ),
                            onMapCreated: _onMapCreated,
                            markers: emissionLocations
                                .where((location) =>
                                    location['latitude'] != null &&
                                    location['longitude'] != null)
                                .map((location) {
                              double? lat =
                                  double.tryParse(location['latitude'] ?? '');
                              double? lng =
                                  double.tryParse(location['longitude'] ?? '');
                              if (lat != null && lng != null) {
                                return Marker(
                                  markerId: MarkerId(location['name']),
                                  position: LatLng(lat, lng),
                                  infoWindow: InfoWindow(
                                    title: location['name'],
                                    snippet: location['address'],
                                  ),
                                );
                              }
                              return Marker(markerId: MarkerId('null'));
                            }).toSet(),
                          ),
                        ),
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
                            updateWorkshops(selectedCity!);
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
                                          "Open ${emissionLocations[index]['openTime']} - ${emissionLocations[index]['closeTime']} everyday",
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "${emissionLocations[index]['distance'].toStringAsFixed(2)} km",
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
            const SizedBox(height: 32),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 186,
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
                child: Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Padding untuk seluruh konten
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header row for first and second columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Hari ini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Image.asset(
                            'assets/img/pin_fill.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 52),
                          Image.asset(
                            'assets/img/daun.png',
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
                              'Belum ada data.',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else ...[
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
                              const SizedBox(width: 16),
                              Text(
                                vehicle.vehicleName,
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 16),
                              ),
                              const Spacer(),
                              const SizedBox(width: 8),
                              Text(
                                '${vehicle.vehicleTravel}km',
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 16),
                              ),
                              const SizedBox(width: 42),
                              Text(
                                '${vehicle.vehicleEmission}kg',
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 16),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
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
