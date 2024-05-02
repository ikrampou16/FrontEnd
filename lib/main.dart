import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FirstPage.dart';
import 'loginScreen.dart';
import 'introScreen.dart';
import 'CachHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CachHelper.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final firstName = prefs.getString('firstName');
  final patientId = prefs.getInt('patientId');

  print('Token: $token');
  print('IsLoggedIn: $isLoggedIn');
  print('FirstName: $firstName');
  print('PatientId: $patientId');

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    firstName: firstName,
    patientId: patientId,
    token:token,
  ));
}

class MyApp extends StatelessWidget {
  final bool? isLoggedIn;
  final String? firstName;
  final int? patientId;
  final String? token;

  const MyApp({Key? key, this.isLoggedIn, this.firstName, this.patientId, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasToken = token != null;
    print('hasToken: $hasToken');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: hasToken ? FirstPage(firstName: firstName!, patientId: patientId) : introScreen(),
      routes: {
        '/login': (context) => loginScreen(),
      },
      builder: (context, child) {
        return child!;
      },
    );
  }
}
