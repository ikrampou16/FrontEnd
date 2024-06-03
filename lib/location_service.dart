import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;

class LocationService {
  static final loc.Location _location = loc.Location();

  static Future<loc.LocationData> fetchLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw 'Location service is not enabled.';
      }
    }

    perm.PermissionStatus permission = await perm.Permission.location.status;
    if (permission == perm.PermissionStatus.denied) {
      permission = await perm.Permission.location.request();
      if (permission != perm.PermissionStatus.granted) {
        throw 'Location permission not granted.';
      }
    }

    return await _location.getLocation();
  }
}
