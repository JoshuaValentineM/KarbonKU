import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Location _location = Location();
  List<LatLng> _routePoints = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> _polylines = {};
  bool _isTracking = false; // Tracking state
  bool _isMapReady = false; // Map readiness state
  int _selectedIndex = 0;
  User? user;
  LatLng? _initialPosition; // To store the initial user location
  double _totalDistance = 0.0; // Variable to store the total distance traveled

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _checkAndRequestPermissions();
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
      _isTracking = !_isTracking;
      if (!_isTracking) {
        _calculateDistanceTraveled();
      } else {
        _routePoints.clear(); // Clear the points when starting new tracking
        _polylines.clear();
        _totalDistance = 0.0;
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
    });
    print('Total Distance Traveled: ${distance.toStringAsFixed(2)} meters');
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
    return earthRadius * c; // Distance in meters
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context);

    return Scaffold(
      body: _isMapReady
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition ?? LatLng(0.0, 0.0),
                    zoom: 17.0,
                  ),
                  mapType: MapType.terrain,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
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
                Positioned(
                  top: 20.0, // Position the distance text
                  left: MediaQuery.of(context).size.width * 0.5 - 60,
                  child: Text(
                    'Distance: ${_totalDistance.toStringAsFixed(2)} m', // Display total distance
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Positioned(
                  bottom: 80.0,
                  left: MediaQuery.of(context).size.width * 0.5 - 60,
                  child: ElevatedButton(
                    onPressed: _toggleTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.red : Colors.green,
                    ),
                    child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(), // Show spinner while loading location
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        user: user,
      ),
    );
  }
}
