



import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> displayNotification(Map<String, dynamic> message) async {
  // Print the entire message object
  print('Received message while app is in the foreground:');
  print(message);

  // Extract notification details from data field
  final String? title = message['title'];
  final String? body = message['body'];
  final String? state = message['state']?.split(':').last.trim(); // Extract the state value only
  final String? acetoneqt = message['acetoneqt'];

  // Display notification details
  print('Title: $title, Body: $body, State: $state, Acetoneqt: $acetoneqt');
}

void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/launcher_icon');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Received message while app is in the foreground:');
    print(message);

    // Retrieve the patient ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final int? loggedInPatientId = prefs.getInt('patientId');

    // Extract the patient ID from the notification data
    final String? notificationPatientId = message.data['patientId'];

    // Only display the notification if the IDs match
    if (loggedInPatientId != null && notificationPatientId == loggedInPatientId.toString()) {
      print('Patient ID match. Displaying notification.');

      displayNotification(message.data);

      // Check if app is in the foreground
      if (WidgetsBinding.instance?.lifecycleState == AppLifecycleState.resumed) {
        print('App is in the foreground.');
        // App is in the foreground, show alert dialog
        showDialog(
          context: navigatorKey.currentState!.overlay!.context,
          builder: (context) {
            return buildNotificationDialog(context, message);
          },
        );
      } else {
        print('App is in the background.');

        // App is in the background, show system notification
        showNotification(message.data);
      }
    } else {
      print('Patient ID does not match. Ignoring notification.');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message:');
  print(message);

  // Retrieve the patient ID from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final int? loggedInPatientId = prefs.getInt('patientId');

  // Extract the patient ID from the notification data
  final String? notificationPatientId = message.data['patientId'];

  // Only display the notification if the IDs match
  if (loggedInPatientId != null && notificationPatientId == loggedInPatientId.toString()) {
    print('Patient ID match. Displaying notification.');
    displayNotification(message.data);

    // App is in the background, show system notification
    showNotification(message.data);
  } else {
    print('Patient ID does not match. Ignoring notification.');
  }
}
Future<void> showNotification(Map<String, dynamic> data) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'high_importance_channel', // Unique channel ID
    'High Importance Notifications', // User-visible channel name
    channelDescription: 'This channel is used for important notifications.', // User-visible channel description
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    ticker: 'ticker',
  );

}
AlertDialog buildNotificationDialog(BuildContext context, RemoteMessage message) {
  final notification = message.notification;
  final Map<String, dynamic> data = message.data;
  String title = notification?.title ?? data['title'] ?? 'Notification';
  final String body = notification?.body ?? data['body'] ?? 'Notification body';
  final String? state = data['state']?.split(':').last.trim(); // Extract the state value only

  // Remove "New Test Result" from title
  if (title == 'New Test Result') {
    title = '';
  }

  // Define dialog color based on state
  Color? dialogColor;
  IconData iconData = Icons.info; // Default icon
  double iconSize = 80; // Increased icon size

  if (state != null) {
    if (state == 'Dangerous') {
      iconData = Icons.warning_amber_outlined;
      dialogColor = Colors.red[400];
    } else if (state == 'Moderate') {
      iconData = Icons.error;
      dialogColor = Colors.orange[400];
    } else if (state == 'Good') {
      iconData = Icons.check_circle;
      dialogColor = Colors.green[400];
    }
  }

  return AlertDialog(
    backgroundColor: dialogColor, // Set dialog background color based on state
    title: Column(
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Icon(
                iconData,
                color: dialogColor,
                size: iconSize,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    ),
    content: Container(
      child: Text(
        textAlign: TextAlign.center,
        body,
        style: TextStyle(
          color: Colors.white, // Set text color to white
          fontFamily: 'Poppins', // Use Poppins font family
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          'Close',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  );
}