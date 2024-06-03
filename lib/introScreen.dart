import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/WelcomeScreen.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0EFE9), Colors.white, Color(0xFFB0EFE9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.09), // Adjust padding based on screen width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1), // Adjust spacing based on screen height
              Container(
                width: screenWidth * 0.3, // Adjust container width based on screen width
                height: screenWidth * 0.3, // Adjust container height based on screen width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.06), // Adjust border radius based on screen width
                  image: DecorationImage(
                    image: AssetImage('assets/logomob.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.09), // Adjust spacing based on screen height
              Text(
                'Enhancing Community Healthcare',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.07, // Adjust font size based on screen width
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.1), // Adjust spacing based on screen height

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
                    borderRadius: BorderRadius.circular(screenWidth * 0.08), // Adjust border radius based on screen width
                  ),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.08), // Adjust padding based on screen dimensions
                  elevation: 5,
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Adjust font size based on screen width
                    color: Color(0xFFB0EFE9),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.10), // Adjust spacing based on screen height
              Text(
                '(We do not aim to replace doctors; rather, we strive to empower them with innovative, advanced tools)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.04, // Adjust font size based on screen width
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
