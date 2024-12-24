import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/model/Vehicle.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import '../middleware/auth_middleware.dart';
import 'carbon_report_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
    _loadVehicleData();
    fetchCities(); // Panggil fungsi untuk mengambil kota
    fetchVehicleReport();
  }

  String formatDate(DateTime date) {
    final today = DateTime.now();
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Hari ini';
    }
    return DateFormat('dd MMM, yyyy').format(date);
  }



  int _selectedIndex = 2; 
  User? user;
  bool isLoading = false;

  final PageController _pageController = PageController();
  double carbonReportPercentageDaily = 0.0; 
  double carbonReportPercentageWeekly = 0.0; 
  double carbonReportPercentageMonthly = 0.0; 
  double carbonReportPercentageYearly = 0.0; 
  double maximumCarbonDaily = 5048;
  double maximumCarbonWeekly = 38460;
  double maximumCarbonMonthly = 166670;
  double maximumCarbonYearly = 200000;

  double totalCarbonEmittedDaily = 0.0; 
  double totalDistanceTraveledDaily = 0.0; 
  double totalCarbonEmittedWeekly = 0.0; 
  double totalDistanceTraveledWeekly = 0.0;
  double totalCarbonEmittedMonthly = 0.0; 
  double totalDistanceTraveledMonthly = 0.0;
  double totalCarbonEmittedYearly = 0.0; 
  double totalDistanceTraveledYearly = 0.0;

  List<Map<String, dynamic>> vehicles = [];
  Map<String, Map<String, double>> groupedDailyData = {};
  List<Vehicle> vehiclesReport = [];

  Future<void> _loadVehicleData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final vehiclesRef = FirebaseFirestore.instance
          .collection('vehicles')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
      final querySnapshot = await vehiclesRef.get();

      List<Vehicle> tempVehiclesReport = [];

      List<Map<String, dynamic>> tempVehicles = [];
      double dailyEmissions = 0.0;
      double dailyDistance = 0.0;
      double weeklyEmissions = 0.0;
      double weeklyDistance = 0.0;
      double monthlyEmissions = 0.0;
      double monthlyDistance = 0.0;
      double yearlyEmissions = 0.0;
      double yearlyDistance = 0.0;

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime oneWeekAgo = today.subtract(Duration(days: 7));
      DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
      DateTime oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      for (var doc in querySnapshot.docs) {
        var vehicleData = doc.data() as Map<String, dynamic>;

        if (vehicleData.containsKey('tracks')) {
          double totalEmission = 0.0;
          double totalDistance = 0.0;

          var tracks = vehicleData['tracks'] as List<dynamic>;
          for (var track in tracks) {
            DateTime? trackDate;

            if (track['date'] is Timestamp) {
              trackDate = (track['date'] as Timestamp).toDate();
            } else if (track['date'] is String) {
              trackDate = DateTime.tryParse(track['date']);
            }

            if (trackDate != null) {
              totalEmission += track['carbon_emission'] ?? 0.0;
              totalDistance += track['distance'] ?? 0.0;
              double carbon = double.tryParse(
                      track['carbon_emission']?.toString() ?? '0.0') ??
                  0.0;
              double distance =
                  double.tryParse(track['distance']?.toString() ?? '0.0') ??
                      0.0;

              if (!trackDate.isBefore(today)) {
                // Hitung juga yang terjadi hari ini
                dailyEmissions += carbon;
                dailyDistance += distance;
              }
              if (!trackDate.isBefore(oneWeekAgo)) {
                // Hitung juga yang terjadi minggu ini
                weeklyEmissions += carbon;
                weeklyDistance += distance;
              }
              if (!trackDate.isBefore(oneMonthAgo)) {
                // Hitung juga yang terjadi bulan ini
                monthlyEmissions += carbon;
                monthlyDistance += distance;
              }
              if (!trackDate.isBefore(oneYearAgo)) {
                // Hitung juga yang terjadi tahun ini
                yearlyEmissions += carbon;
                yearlyDistance += distance;
              }

              print(
                  "Track Date: $trackDate, Carbon: $carbon, Distance: $distance");
            }
          }

          tempVehiclesReport.add(Vehicle(
            vehicleType: vehicleData['vehicleType'] ?? 'Unknown',
            vehicleName: vehicleData['vehicleName'] ?? 'Unknown',
            vehicleEmission: totalEmission,
            vehicleTravel: totalDistance,
          ));
        }
      }

      setState(() {
        vehiclesReport = tempVehiclesReport;
        totalCarbonEmittedDaily = dailyEmissions;
        totalDistanceTraveledDaily = dailyDistance;
        totalCarbonEmittedWeekly = weeklyEmissions;
        totalDistanceTraveledWeekly = weeklyDistance;
        totalCarbonEmittedMonthly = monthlyEmissions;
        totalDistanceTraveledMonthly = monthlyDistance;
        totalCarbonEmittedYearly = yearlyEmissions;
        totalDistanceTraveledYearly = yearlyDistance;

        // Kalkulasi persentase emisi tanpa pembagian 1000
        carbonReportPercentageDaily =
            (dailyEmissions / maximumCarbonDaily) * 100;
        carbonReportPercentageWeekly =
            (weeklyEmissions / maximumCarbonWeekly) * 100;
        carbonReportPercentageMonthly =
            (monthlyEmissions / maximumCarbonMonthly) * 100;
        carbonReportPercentageYearly =
            (yearlyEmissions / maximumCarbonYearly) * 100;

        isLoading = false;
      });
    } catch (e) {
      print("Error loading vehicle data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> cityList = [];
  String? selectedCity;
  List<Map<String, dynamic>> emissionLocations = [];

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

  Map<String, Map<String, double>> dailyData = {};
  Map<String, List<Map<String, dynamic>>> detailedDailyData = {};

  void fetchVehicleReport() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, List<Map<String, dynamic>>> tempDetailedDailyData = {};

    for (var doc in querySnapshot.docs) {
      var vehicleData = doc.data() as Map<String, dynamic>;

      if (vehicleData.containsKey('tracks')) {
        var tracks = vehicleData['tracks'] as List<dynamic>;
        for (var track in tracks) {
          DateTime? trackDate;

          if (track['date'] is Timestamp) {
            trackDate = (track['date'] as Timestamp).toDate();
          } else if (track['date'] is String) {
            trackDate = DateTime.tryParse(track['date']);
          }

          if (trackDate != null) {
            String dateKey = trackDate.toIso8601String().split('T').first;

            double carbon = double.tryParse(
                    track['carbon_emission']?.toString() ?? '0.0') ??
                0.0;
            double distance =
                (double.tryParse(track['distance']?.toString() ?? '0.0') ??
                        0.0) /
                    1000;

            if (!tempDetailedDailyData.containsKey(dateKey)) {
              tempDetailedDailyData[dateKey] = [];
            }

            tempDetailedDailyData[dateKey]!.add({
              'vehicleName': vehicleData['vehicleName'] ?? 'Unknown',
              'vehicleType': vehicleData['vehicleType'] ?? 'unknown',
              'carbonEmission': carbon,
              'distance': distance,
            });
          }
        }
      }
    }

    // Mengurutkan data berdasarkan tanggal (dateKey)
    var sortedKeys = tempDetailedDailyData.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    // Menyusun data yang sudah diurutkan
    Map<String, List<Map<String, dynamic>>> sortedData = {};
    for (var key in sortedKeys) {
      sortedData[key] = tempDetailedDailyData[key]!;
    }

    setState(() {
      detailedDailyData = sortedData;
    });
  }

  Future<void> fetchCities() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('test_emission_locations')
          .get();

      setState(() {
        cityList = querySnapshot.docs.map((doc) => doc.id).toList();

        // Set "Jakarta Barat" as default if available
        if (cityList.contains('Jakarta Barat')) {
          selectedCity = 'Jakarta Barat';
        } else {
          selectedCity = cityList.isNotEmpty ? cityList[0] : null;
        }
      });

      // Fetch workshops for the default city
      if (selectedCity != null) {
        await fetchWorkshops(selectedCity!);
      }
    } catch (e) {
      print("Error fetching cities: $e");
    } finally {
      setState(() {
        isLoading = false;
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
          insetPadding: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.all(15),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width *
                  0.85, // Atur lebar maksimal popup sesuai kebutuhan
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
                  const SizedBox(height: 5), // Add some space
                  // Description text
                  const Text.rich(
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

  Future<void> updateWorkshops(String city) async {
    try {
      setState(() {
        isLoading = true;
      });

      await fetchWorkshops(city);

      // Move the camera to the first workshop location if available
      if (emissionLocations.isNotEmpty) {
        double? lat = double.tryParse(emissionLocations[0]['latitude'] ?? '');
        double? lng = double.tryParse(emissionLocations[0]['longitude'] ?? '');

        if (lat != null && lng != null) {
          _mapController!.animateCamera(
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

  GoogleMapController? _mapController;

  void _onMapCreated(GoogleMapController controller) {
    if (_mapController == null) {
      _mapController = controller;
    }
  }

  void _showEmissionTestPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            LatLng initialLocation =
                LatLng(-6.200000, 106.816666); // Jakarta coordinates
            Set<Marker> _markers = {};

            void _zoomToWorkshop(Map<String, dynamic> workshop) async {
              double? lat = double.tryParse(workshop['latitude'] ?? '');
              double? lng = double.tryParse(workshop['longitude'] ?? '');
              print("Workshop selected: ${workshop['name']}");
              print("Target coordinates: $lat, $lng");

              if (lat != null && lng != null) {
                LatLng target = LatLng(lat, lng);

                // Perbarui markers
                setState(() {
                  _markers = {
                    Marker(
                      markerId: MarkerId(workshop['name']),
                      position: target,
                      infoWindow: InfoWindow(
                        title: workshop['name'],
                        snippet: workshop['address'],
                      ),
                    ),
                  };
                });

                print("_mapController: $_mapController");
                // Zoom-in ke lokasi marker
                if (_mapController != null) {
                  await _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: target, zoom: 15),
                    ),
                  );
                }
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.6,
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
                            markers: _markers.isNotEmpty
                                ? _markers
                                : emissionLocations
                                    .where((location) =>
                                        location['latitude'] != null &&
                                        location['longitude'] != null)
                                    .map((location) {
                                    double? lat = double.tryParse(
                                        location['latitude'] ?? '');
                                    double? lng = double.tryParse(
                                        location['longitude'] ?? '');
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
                            zoomControlsEnabled: false,
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
                            // Call updateWorkshops after updating the selected city.
                            updateWorkshops(newValue);
                          }
                        },
                        isExpanded: true,
                        underline: SizedBox(),
                        items: cityList.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city, style: TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: emissionLocations.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 16, // Jarak vertikal antara item dan garis
                          ),
                          itemBuilder: (context, index) {
                            final workshop = emissionLocations[index];
                            return GestureDetector(
                              onTap: () => _zoomToWorkshop(workshop),
                              child: Padding(
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
                                            workshop['name'] as String,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(workshop['address'] as String),
                                          Text(
                                            "Open ${workshop['openTime']} - ${workshop['closeTime']} everyday",
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        "${workshop['distance'].toStringAsFixed(2)} km",
                                        textAlign: TextAlign.right,
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
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

  void _showDetailedDataPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.6,
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                      },
                      border: null,
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0).add(EdgeInsets.symmetric(vertical: 2.0)),
                              child: Text(
                                "Detail",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                'assets/img/pin_fill.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                'assets/img/daun.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    if (detailedDailyData.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 112.0),
                          child: Text(
                            'Belum ada data.',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        border: null,
                        children: [
                          ...detailedDailyData.entries.expand((entry) {
                            final date = DateTime.parse(entry.key); // Ubah key menjadi DateTime
                            final formattedDate = formatDate(date);
                            final vehicles = entry.value;

                            return [
                              // Date Row
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0).add(EdgeInsets.symmetric(vertical: 8.0)),
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(),
                                  const SizedBox(),
                                ],
                              ),
                              // Vehicle Rows
                              ...vehicles.map((vehicle) {
                                final vehicleName = vehicle['vehicleName'];
                                final vehicleType = vehicle['vehicleType'];
                                final carbonEmission = vehicle['carbonEmission'] ?? 0.0;
                                final distance = vehicle['distance'] ?? 0.0;

                                String iconPath;
                                if (vehicleType == 'motor') {
                                  iconPath = 'assets/img/motor.png';
                                } else if (vehicleType == 'mobil') {
                                  iconPath = 'assets/img/mobil.png';
                                } else {
                                  iconPath = '';
                                }

                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0).add(EdgeInsets.symmetric(vertical: 8.0)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if (iconPath.isNotEmpty)
                                            Image.asset(
                                              iconPath,
                                              width: 18,
                                              height: 18,
                                            ),
                                          const SizedBox(width: 8),
                                          Text(
                                            vehicleName,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Center(
                                        child: Text(
                                          '${distance.toStringAsFixed(1)} km',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Center(
                                        child: Text(
                                          '${(carbonEmission / 1000).toStringAsFixed(1)} kg',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ];
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context); // Middleware auth
    // Ambil data terakhir (jika ada)
    final lastDate =
        detailedDailyData.keys.isNotEmpty ? detailedDailyData.keys.last : null;
    final lastData = lastDate != null ? detailedDailyData[lastDate] : [];

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
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Menampilkan loading indicator saat isLoading = true
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                      height: 32), // Jarak lebih besar di bagian atas
                  SizedBox(
                    height: 225, // Atur tinggi untuk PageView
                    child: PageView(
                      controller: _pageController,
                      children: [
                        CarbonReportView(
                          carbonReportPercentage: carbonReportPercentageDaily,
                          totalCarbonEmitted: totalCarbonEmittedDaily,
                          totalDistanceTraveled: totalDistanceTraveledDaily,
                          reportType: 'Daily',
                          currentPage: 0,
                        ),
                        CarbonReportView(
                          carbonReportPercentage: carbonReportPercentageWeekly,
                          totalCarbonEmitted: totalCarbonEmittedWeekly,
                          totalDistanceTraveled: totalDistanceTraveledWeekly,
                          reportType: 'Weekly',
                          currentPage: 1,
                        ),
                        CarbonReportView(
                          carbonReportPercentage: carbonReportPercentageMonthly,
                          totalCarbonEmitted: totalCarbonEmittedMonthly,
                          totalDistanceTraveled: totalDistanceTraveledMonthly,
                          reportType: 'Monthly',
                          currentPage: 2,
                        ),
                        CarbonReportView(
                          carbonReportPercentage: carbonReportPercentageYearly,
                          totalCarbonEmitted: totalCarbonEmittedYearly,
                          totalDistanceTraveled: totalDistanceTraveledYearly,
                          reportType: 'Yearly',
                          currentPage: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => _showDetailedDataPopup(context),
                    child: Center(
                      child: Container(
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header Row
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                  },
                                  border: null,
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.0).add(EdgeInsets.symmetric(vertical: 2.0)),
                                          child: Text(
                                            "Hari ini",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Image.asset(
                                            'assets/img/pin_fill.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                        Center(
                                          child: Image.asset(
                                            'assets/img/daun.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Content Rows
                                Builder(
                                  builder: (context) {
                                    final today = DateTime.now();
                                    final todayKey =
                                        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

                                    if (detailedDailyData
                                        .containsKey(todayKey)) {
                                      final vehicles =
                                          detailedDailyData[todayKey] ?? [];

                                      return Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(3),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(2),
                                        },
                                        border: null,
                                        children: vehicles.map((vehicle) {
                                          final vehicleName =
                                              vehicle['vehicleName'];
                                          final vehicleType =
                                              vehicle['vehicleType'];
                                          final carbonEmission =
                                              vehicle['carbonEmission'] ?? 0.0;
                                          final distance =
                                              vehicle['distance'] ?? 0.0;

                                          String iconPath;
                                          if (vehicleType == 'motor') {
                                            iconPath = 'assets/img/motor.png';
                                          } else if (vehicleType == 'mobil') {
                                            iconPath = 'assets/img/mobil.png';
                                          } else {
                                            iconPath = '';
                                          }

                                          return TableRow(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(left: 8.0).add(EdgeInsets.symmetric(vertical: 8.0)),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (iconPath.isNotEmpty)
                                                      Image.asset(
                                                        iconPath,
                                                        width: 18,
                                                        height: 18,
                                                      ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      vehicleName,
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Center(
                                                  child: Text(
                                                    '${distance.toStringAsFixed(1)} km',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Center(
                                                  child: Text(
                                                    '${(carbonEmission / 1000).toStringAsFixed(1)} kg',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      );
                                    } else {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 16.0),
                                          child: Text(
                                            'Tidak ada data.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 32), // Jarak antar widget yang lebih besar
                  GestureDetector(
                    onTap: () => _showCarbonStandardPopup(context),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height:
                            215, // Matching the height of Carbon Report widget
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          image: const DecorationImage(
                            image: AssetImage(
                                'assets/img/carbon_standard_fix.png'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset:
                                  Offset(0, 10), // Larger shadow at the bottom
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "MAXIMUM",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              36, // Adjusted size for MAXIMUM
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
                                  SizedBox(
                                      width: 16), // Space between text and icon
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

                  const SizedBox(
                      height: 32), // Jarak antar widget yang lebih besar
                  GestureDetector(
                    onTap: () => _showEmissionTestPopup(context),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height:
                            215, // Matching the height of Carbon Report widget
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
                              offset:
                                  Offset(0, 10), // Shadow lebih besar di bawah
                            ),
                          ],
                        ),
                        child: Stack(
                          // Menggunakan Stack untuk lapisan
                          children: [
                            // Layer gelap pertama
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withOpacity(0.3), // Gelap 30%
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
                                  color: Colors.black
                                      .withOpacity(0.5), // Gelap 50%
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(20.0),
                                  ),
                                ),
                                padding:
                                    EdgeInsets.only(left: 18.0, right: 8.0, top: 2.0, bottom: 2.0), // Padding untuk teks
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Lokasi Uji Emisi",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28, // Perbesar ukuran font
                                        fontWeight: FontWeight
                                            .w500, // Set ketebalan font sama
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
                                            fontWeight: FontWeight
                                                .w500, // Samakan ketebalan
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                8), // Jarak antara teks dan ikon
                                        Icon(
                                          Icons
                                              .arrow_forward, // Ikon panah ke kanan
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

                  const SizedBox(
                      height: 32), // Jarak lebih besar di bagian bawah
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
