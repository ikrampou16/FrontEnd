// IntroScreen.dart
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
            Text(
              'App Name!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF199A8E),
              ),
            ),
            SizedBox(height: 70),
            Text(
              'Striving to enhance \n community healthcare  and advance \n surveillance technologies!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 70),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 2), // Adjust the offset for a bottom drop shadow
                  ),
                ],
              ),
              child: ElevatedButton(
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
                ),
                child: Icon(Icons.arrow_forward, size: 30, color: Color(0xFFB0EFE9)),
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: Image(
                image: AssetImage('assets/intro.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
