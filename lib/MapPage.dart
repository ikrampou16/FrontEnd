import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_urls.dart';
import 'status_code.dart';

class MyMapPage extends StatefulWidget {
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  late MapController _mapController;
  bool _isLoading = true;
  LatLng? _latestLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getLatestLocation();
  }

  Future<void> _getLatestLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse(ApiUrls.latestLocationUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == StatusCodes.ok) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['latitude'] != null && data['longitude'] != null) {
          final double latitude = data['latitude'];
          final double longitude = data['longitude'];

          setState(() {
            _latestLocation = LatLng(latitude, longitude);
            _mapController.move(_latestLocation!, 13.0);
            _isLoading = false; // Set loading to false after fetching location
          });
        } else {
          throw Exception('No location data available');
        }
      } else if (response.statusCode == StatusCodes.notFound) {
        // Handle the case where no location is found
        print('No location found in the database, using device location.');
        await _fetchDeviceLocation();
      } else {
        throw Exception('Failed to load latest location: ${StatusCodes.getMessage(response.statusCode)}');
      }
    } catch (e) {
      print('Error fetching latest location: $e');
      // Fetch device's current location since latest location is not available
      await _fetchDeviceLocation();
    }
  }

  Future<void> _fetchDeviceLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _latestLocation = LatLng(_locationData!.latitude!, _locationData.longitude!);
      _mapController.move(_latestLocation!, 13.0);
      _isLoading = false; // Set loading to false after fetching location
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _latestLocation ?? LatLng(0, 0), // Center map on latest location if available
              zoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              if (_latestLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _latestLocation!,
                      width: 40.0,
                      height: 40.0,
                      child: Container(
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(), // Loading indicator
            ),
        ],
      ),
    );
  }
}
