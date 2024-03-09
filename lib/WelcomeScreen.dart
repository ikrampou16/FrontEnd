import 'package:flutter/material.dart';
import 'package:untitled3/regScreen.dart';
import 'loginScreen.dart';
import 'introScreen.dart'; // Import your introScreen file

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int selectedOption = 0; // 0 for Sign In, 1 for Sign Up

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => introScreen()), // Replace IntroScreen() with your actual class name
        );
        return true; // Return true to allow the back button press
      },
      child: Scaffold(
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
            children: [
              Image(
                image: AssetImage('assets/welpage.jpg'),
                fit: BoxFit.cover,
              ),
              SizedBox(height: 50),
              Text(
                'Connect with us!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  shadows: [
                    Shadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100),
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  // Detect horizontal drag to switch between buttons
                  if (details.primaryDelta != null) {
                    setState(() {
                      selectedOption = details.primaryDelta! > 0 ? 0 : 1;
                    });
                  }
                },
                onHorizontalDragEnd: (details) {
                  // Navigate to the corresponding screen based on the selected option
                  if (selectedOption == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const loginScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  RegScreen()),
                    );
                  }
                },
                child: ToggleButtons(
                  isSelected: [selectedOption == 0, selectedOption == 1],
                  borderRadius: BorderRadius.circular(30),
                  children: [
                    Container(
                      height: 53,
                      width: 150,
                      decoration: BoxDecoration(
                        color: selectedOption == 0 ? Color(0xFF199A8E) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Color(0xFF199A8E)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.transparent,
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selectedOption == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 53,
                      width: 150,
                      decoration: BoxDecoration(
                        color: selectedOption == 1 ? Color(0xFF199A8E) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Color(0xFF199A8E)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.transparent,
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selectedOption == 1 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
