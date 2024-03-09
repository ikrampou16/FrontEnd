import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/auth_provider.dart';
import 'IntroScreen.dart'; // Import the IntroScreen

import 'WelcomeScreen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'inter',
          useMaterial3: true,
        ),
        home: introScreen(), // Set IntroScreen as the home page
      ),
    ),
  );
}
