import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/test.dart';
import 'SplashScreen.dart';
import 'FirstPage.dart';
import 'firebase.dart';
import 'loginScreen.dart';
import 'CachHelper.dart';
import 'dart:convert';
import 'api_urls.dart';
import 'notification_manager.dart';
import 'location_service.dart';
import 'package:http/http.dart' as http;
import 'status_code.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CachHelper.init();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDZJ_qek0UF4cS_sQNRBKMmueIn93Aqidg',
      appId: '1:959007708327:android:1347dd97129b1eac593782',
      messagingSenderId: '959007708327',
      projectId: 'fluttermob-33120',
      storageBucket: 'fluttermob-33120.appspot.com',
    ),
  );
  AppLifecycleObserver lifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance!.addObserver(lifecycleObserver);

  // Fetch and send location
  await _fetchAndSendLocation();
  initializeNotifications();
  await requestNotificationPermissionIfNeeded(); // Request notification permission

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  final prefs = await SharedPreferences.getInstance();
  final recommendation = prefs.getString('recommendation') ?? '';
  final token = prefs.getString('token');
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final firstName = prefs.getString('firstName');
  final patientId = prefs.getInt('patientId');
  final pythonOutput = prefs.getString('pythonOutput') ?? '';
  final age = prefs.getInt('age') ?? 0;
  final gender = prefs.getString('gender') ?? '';
  final diabetesType = prefs.getString('diabetesType') ?? '';
  final area = prefs.getString('area') ?? '';
  final isSmoke = prefs.getString('isSmoke') ?? '';

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    await updateFCMToken(patientId.toString(), fcmToken);
  }


  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    firstName: firstName,
    patientId: patientId,
    token: token,
    pythonOutput: pythonOutput,
    age: age,
    gender: gender,
    diabetesType: diabetesType,
    area: area,
    isSmoke: isSmoke,
  ));
}

Future<void> _fetchAndSendLocation() async {
  try {
    final locationData = await LocationService.fetchLocation();
    double mobLatitude = locationData.latitude!;
    double mobLongitude = locationData.longitude!;
    await _sendMobileLocationToServer(mobLatitude, mobLongitude);
  } catch (e) {
    print('Failed to fetch location: $e');
  }
}

Future<void> _sendMobileLocationToServer(double latitude, double longitude) async {
  final url = Uri.parse(ApiUrls.sendLocationUrl);
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'MobLatitude': latitude,
      'MobLongitude': longitude,
    }),
  );

  if (response.statusCode == StatusCodes.ok) {
    print('Mobile location sent successfully');
  } else {
    print('Failed to send mobile location, status code: ${response.statusCode}');
  }
}

Future<void> requestNotificationPermissionIfNeeded() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? notificationPermissionRequested = prefs.getBool('notificationPermissionRequested');
  if (notificationPermissionRequested == null || !notificationPermissionRequested) {
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

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    await prefs.setBool('notificationPermissionRequested', true);
  }
}

class MyApp extends StatelessWidget {
  final bool? isLoggedIn;
  final String? firstName;
  final int? patientId;
  final String? token;
  final String? pythonOutput;
  final int? age;
  final String? gender;
  final String? diabetesType;
  final String? area;
  final String? isSmoke;

  const MyApp({
    Key? key,
    this.isLoggedIn,
    this.firstName,
    this.patientId,
    this.token,
    this.pythonOutput,
    this.age,
    this.gender,
    this.diabetesType,
    this.area,
    this.isSmoke,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            (token != null &&
                firstName != null &&
                patientId != null &&
                pythonOutput != null &&
                age != null &&
                gender != null &&
                diabetesType != null &&
                area != null &&
                isSmoke != null)
                ? FirstPage(
              firstName: firstName!,
              patientId: patientId!,
              pythonOutput: pythonOutput!,
              age: age!,
              gender: gender!,
              diabetesType: diabetesType,
              area: area,
              isSmoke: isSmoke,
            )
                : SplashScreen(),
          ],
        ),
      ),
      routes: {
        '/login': (context) => loginScreen(),
      },
    );
  }
}
