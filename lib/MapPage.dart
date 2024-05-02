import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;

class MyMapPage extends StatefulWidget {
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  late MapController _mapController;
  late loc.LocationData _currentLocation;
  late loc.Location _location = loc.Location();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    perm.PermissionStatus permission;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permission = await perm.Permission.location.status;
    if (permission == perm.PermissionStatus.denied) {
      permission = await perm.Permission.location.request();
      if (permission != perm.PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location.getLocation();
    setState(() {
      _mapController.move(
        LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
        13.0,
      );
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
              center: LatLng(0, 0),
              zoom: 10.0,
              maxZoom: 18.0,
              onPositionChanged: (pos, b) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              CurrentLocationLayer(),
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
