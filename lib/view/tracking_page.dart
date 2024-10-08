import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import '../middleware/auth_middleware.dart';

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

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

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
        }
        _mapController.animateCamera(
          CameraUpdate.newLatLng(currentLatLng),
        );
      });
    });
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
      }
    });
  }

  void _calculateDistanceTraveled() {
    double totalDistance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += _calculateDistanceBetweenPoints(
        _routePoints[i],
        _routePoints[i + 1],
      );
    }
    print('Total Distance Traveled: ${totalDistance.toStringAsFixed(2)} meters');
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
                    zoom: 14.0,
                  ),
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
