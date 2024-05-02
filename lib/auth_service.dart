import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHelper {
  static Future<void> logout(BuildContext context) async {
    final storage = FlutterSecureStorage();

    // Show a confirmation dialog
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF199A8E)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if user confirms logout
              },
              child: Text(
                'Logout',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await storage.delete(key: 'token');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        print('Error during logout: $e');
      }
    }
  }
}