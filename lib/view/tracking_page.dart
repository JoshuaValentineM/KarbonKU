import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import '../middleware/auth_middleware.dart';
import 'dart:math';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late GoogleMapController _mapController;
  Key _mapKey = UniqueKey();

  Location _location = Location();
  List<LatLng> _routePoints = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> _polylines = {};
  bool _isTracking = false;
  bool _isShowTrackingInfo = false;
  bool _isMapReady = false;
  int _selectedIndex = 0;
  User? user;
  LatLng? _initialPosition;

  double _totalDistance = 0.0;
  double _totalEmission = 0.0;

  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoadingVehicles = true;
  String? _selectedVehicleId;
  String? _lastVehicleId;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _checkAndRequestPermissions();
    _fetchVehicles();
  }

  Future<void> _checkAndRequestPermissions() async {
    bool granted = await _requestPermissions();

    // Continue requesting permissions until granted or the user denies indefinitely
    while (!granted) {
      _showSnackBar('Permissions are required to use this feature.');
      granted = await _requestPermissions();
    }

    // If we have all the necessary permissions, proceed with initialization
    if (granted) {
      _initializeBackgroundService();
      _getCurrentLocation();
    }
  }

  Future<bool> _requestPermissions() async {
    // Check if location services are enabled
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return false; // Location services not enabled
      }
    }

    // Check for location permissions
    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // Show SnackBar if permission is denied
        _showSnackBar("Location permissions need to be granted.");
        return false;
      }
    }

    // Check for background service permission
    bool backgroundPermissionGranted = await FlutterBackground.hasPermissions;
    if (!backgroundPermissionGranted) {
      // Show SnackBar if background service permission is denied
      bool success = await FlutterBackground.initialize();
      if(!success) {
        _showSnackBar("Background service permissions need to be granted.");
        return false;
      }
    } else {
      bool success = await FlutterBackground.initialize();
      await FlutterBackground.enableBackgroundExecution();
    }

    return true; // Both permissions granted
  }

  Future<void> _initializeBackgroundService() async {
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      LatLng currentLatLng = LatLng(location.coords.latitude, location.coords.longitude);
      
      setState(() {
        if (_isTracking) {
          _routePoints.add(currentLatLng);
          _updatePolyline();
          _updateTotalDistance(currentLatLng);
        }
      });
    });

    bg.BackgroundGeolocation.start();
  }

  Future<void> _getCurrentLocation() async {
    // Get the user's current location
    LocationData currentLocation = await _location.getLocation();
    setState(() {
      _initialPosition = LatLng(
        currentLocation.latitude ?? 0.0,
        currentLocation.longitude ?? 0.0,
      );
      _isMapReady = true; // Mark the map as ready once the location is obtained
      _initializeLocationTracking(); // Start tracking after getting the initial location
    });
  }

  void _initializeLocationTracking() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      LatLng currentLatLng = LatLng(
        currentLocation.latitude ?? 0.0,
        currentLocation.longitude ?? 0.0,
      );

      setState(() {
        if (_isTracking) {
          _routePoints.add(currentLatLng);
          _updatePolyline();
          _updateTotalDistance(currentLatLng);
        }
        _mapController.animateCamera(
          CameraUpdate.newLatLng(currentLatLng),
        );
      });
    });
  }

  void _goToMyLocation() {
    if (_mapController != null && _initialPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_initialPosition!),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateTotalDistance(LatLng newPoint) {
    if (_routePoints.length > 1) {
      double distance = _calculateDistanceBetweenPoints(
        _routePoints[_routePoints.length - 2],
        newPoint,
      );
      setState(() {
        _totalDistance += distance;
        final vehicle = _vehicles.firstWhere(
          (v) => v['id'] == _lastVehicleId
        );
        _totalEmission += distance * vehicle['emission'];
      });
    }
  }

  void _updatePolyline() {
    Polyline polyline = Polyline(
      polylineId: const PolylineId('tracking_route'),
      color: Colors.blue,
      width: 5,
      points: _routePoints,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  void _toggleTracking() {
    setState(() {
      _isShowTrackingInfo = true;
      _isTracking = !_isTracking;
      _mapKey = UniqueKey();
      if (!_isTracking) {
        _calculateDistanceTraveled();
      } else {
        _lastVehicleId = _selectedVehicleId;
        _routePoints.clear();
        _polylines.clear();
        _totalDistance = 0.0;
        _totalEmission = 0.0;
      }
    });
  }

  void _calculateDistanceTraveled() {
    double distance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      distance += _calculateDistanceBetweenPoints(
        _routePoints[i],
        _routePoints[i + 1],
      );
    }
    setState(() {
      _totalDistance = distance;
      final vehicle = _vehicles.firstWhere(
        (v) => v['id'] == _lastVehicleId
      );
      _totalEmission = distance * vehicle['emission'];
    });
    print('Total Distance Traveled: ${_totalDistance.toStringAsFixed(2)} meters');
    print('Total Emission Produced: ${_totalEmission.toStringAsFixed(2)} grams');

    final trackingData = {
      'distance': _totalDistance,
      'carbon_emission': _totalEmission,
      'date': DateTime.now(),
    };

    try {
      FirebaseFirestore.instance.collection('vehicles').doc(_lastVehicleId).update({
        'tracks': FieldValue.arrayUnion([trackingData]),
      });
      
      _showSnackBar('Tracking data updated successfully.');
    } catch (e) {
      _showSnackBar('Failed to update tracking data: $e');
    }
  }

  double _calculateDistanceBetweenPoints(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Radius of the Earth in meters
    double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    double dLon = _degreesToRadians(point2.longitude - point1.longitude);
    double a = 
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _fetchVehicles() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final FirebaseAuth auth = FirebaseAuth.instance;

      QuerySnapshot snapshot = await firestore
          .collection('vehicles')
          .where('userId', isEqualTo: auth.currentUser!.uid)
          .get();

      setState(() {
        _vehicles = snapshot.docs.map((doc) {
          String iconPath;
          double emission;
          if (doc['vehicleType'] == 'motor') {
            iconPath = 'assets/img/motorcycle_icon.png';
            emission = 0.153;
          } else if (doc['vehicleType'] == 'mobil' && doc['fuelType'] == 'Diesel'){
            iconPath = 'assets/img/car_icon.png';
            emission = 0.265;
          } else {
            iconPath = 'assets/img/car_icon.png';
            emission = 0.229;
          }

          return {
            "id": doc.id,
            "name": doc['vehicleName'],
            "emission": emission,
            "icon": iconPath,
          };
        }).toList();
        _isLoadingVehicles = false; // Set loading to false once data is fetched
      });
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false; // Handle the error by stopping the loading spinner
      });
      print('Error fetching vehicles: $e');
    }
  }

  Widget _buildVehicleList(BuildContext context) {
    if (_isLoadingVehicles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vehicles.isEmpty) {
      return const Center(child: Text('No vehicles found'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _vehicles.map((vehicle) {
          bool isSelected = _selectedVehicleId == vehicle["id"];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isTracking ? const Color(0xFF6C7072) : (isSelected ? const Color(0xFF66D6A6) : const Color(0xFF1A373B)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Image.asset(
                      vehicle["icon"]!,
                      width: 25,
                    ),
                    iconSize: 25,
                    onPressed:
                    _isTracking ? null : () {
                      setState(() {
                        _selectedVehicleId = vehicle["id"];
                        print(_selectedVehicleId);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    vehicle["name"]!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrackingInfo() {
    // Get the logo path for the selected vehicle
    final vehicle = _vehicles.firstWhere(
      (v) => v['id'] == _lastVehicleId
    );
    final logoPath = vehicle['icon'] ?? '';

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            FractionallySizedBox(
              widthFactor: 0.9,
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A373B), Color(0xFF3B645E)],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center-aligns the columns horizontally
                    children: [
                      // Left Column: Carbon Emission
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Centers content vertically in each column
                            children: [
                              const SizedBox(height: 16.0),
                              Text(
                                (_totalEmission < 10000) ? (_totalEmission / 1000).toStringAsFixed(1) : (_totalEmission / 1000).toStringAsFixed(0), 
                                style: const TextStyle(fontSize: 80, color: Color(0xFF66D6A6), height: 1),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/img/leaf.png',
                                    width: 14.0,
                                    height: 14.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  const Text(
                                    'kg diproduksi',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.white,
                        thickness: 1.25,
                        width: 64,
                        indent: 70,
                      ),
                      // Right Column: Distance
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16.0),
                              Text(
                                (_totalDistance < 10000) ? (_totalDistance / 1000).toStringAsFixed(1) : (_totalDistance / 1000).toStringAsFixed(0), // Convert meters to kilometers
                                style: const TextStyle(fontSize: 80, color: Color(0xFF66D6A6), height: 1),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/img/pin_range.png',
                                    width: 14.0,
                                    height: 14.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  const Text(
                                    'km ditempuh',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
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
            // Circular Badge for Vehicle Logo
            Positioned(
              top: -40,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6.0,
                          spreadRadius: 1.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1A373B),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: logoPath.isNotEmpty
                          ? Image.asset(
                            logoPath,
                            fit: BoxFit.contain,
                          )
                          : const Icon(
                            Icons.error,
                            size: 30,
                            color: Colors.white, // Icon color to match background
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0), // Spacing between icon and text
                  SizedBox(
                      width: 80,
                      child: Text(
                        vehicle["name"]!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B645E),
        elevation: 0,
        title: const Text(
          'Tracking',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isMapReady
          ? Stack(
              children: [
                GoogleMap(
                  key: _mapKey,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition ?? LatLng(0.0, 0.0),
                    zoom: 17.0,
                  ),
                  mapType: MapType.terrain,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_initialPosition != null) {
                      _mapController.animateCamera(
                        CameraUpdate.newLatLng(_initialPosition!),
                      );
                    }
                  },
                  polylines: _polylines,
                ),
                if (_isShowTrackingInfo) _buildTrackingInfo(),
                Positioned(
                  bottom: 200,
                  right: 32,
                  child: FloatingActionButton(
                    onPressed: _goToMyLocation,
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 48,
                  left: 32,
                  right: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // Rounded edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildVehicleList(context),
                        ),
                        const SizedBox(width: 16.0), // Spacing between list and button
                        ElevatedButton(
                          onPressed: _selectedVehicleId == null ? null : _toggleTracking, // Disable button if no vehicle is selected
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(108.0, 0.0),
                            backgroundColor: _selectedVehicleId == null ? Colors.grey : (_isTracking ? const Color(0xFFD66666) : const Color(0xFF66D6A6)),
                          ),
                          child: Text(
                            _isTracking ? 'Berhenti' : 'Mulai',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: _isTracking 
      ? null 
      : CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        user: user,
      ),
    );
  }
}
