// IntroScreen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/WelcomeScreen.dart';

class introScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFB0EFE9)],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 90),
            Container(
              width: 140.0,
              height: 120.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                image: DecorationImage(
                  image: AssetImage('assets/logomob.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Striving to enhance\ncommunity healthcare and advance\nsurveillance technologies!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 55),
            ElevatedButton(
              onPressed: () {
                // Navigate to the WelcomeScreen after the introduction
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                elevation: 5, // Add elevation for a more prominent button
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 30,
                color: Color(0xFFB0EFE9),
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: Image.asset(
                'assets/intro.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}