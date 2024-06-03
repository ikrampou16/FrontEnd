import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_urls.dart';
import 'status_code.dart';

Future<void> updateFCMToken(String patientId, String? fcmToken) async {
  if (fcmToken == null) {
    print('FCM token is null. Cannot update FCM token.');
    return;
  }

  print(fcmToken);
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  final Map<String, dynamic> body = {
    'fcmToken': fcmToken,
  };

  try {
    final response = await http.post(
      Uri.parse(ApiUrls.fcmTokenUrl(int.parse(patientId))),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == StatusCodes.ok) {
      print('FCM token updated successfully');
    } else {
      print('Failed to update FCM token. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Error message: ${StatusCodes.getMessage(response.statusCode)}');
    }
  } catch (error) {
    print('Error updating FCM token: $error');
  }
}
