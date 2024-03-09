import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:untitled3/auth_provider.dart';
import 'FirstPage.dart';
import 'regScreen.dart';


class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  late String email;
  late String password;

  // Function to handle user login
  Future<void> loginUser(BuildContext context) async {
    // Check if email or password is empty
    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      print('Login button pressed');
      print('Sending login request...');
      print('Email: $email');

      final response = await http.post(
        Uri.parse('http://192.168.1.6:3000/api/patient/loginPatient'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Login successful
        print('Login successful: ${response.body}');
        // Navigate to the FirstPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirstPage(userName: 'User'),
          ),
        );
      } else {
        // Login failed
        // Display an error message
        print('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error during login: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFB0EFE9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 340,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Hello Again!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Image.asset(
                        'assets/login.png', // Replace with your image asset path
                        width: 100, // Adjust width as needed
                        height: 150, // Adjust height as needed
                      ),
                      Text(
                        'Welcome back, you\'ve been missed!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      onChanged: (value) {
                        // Update the email value
                        email = value;
                        print('Email: $email');
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Color(0xFF199A8E)),
                        labelText: 'Username or Email',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(0xFF199A8E)), // Focused border color
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      obscureText: true,
                      onChanged: (value) {
                        // Update the password value
                        password = value;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF199A8E)),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(0xFF199A8E)), // Focused border color
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Recovery Password',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF199A8E),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        await loginUser(context); // Call the loginUser function with the context
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF199A8E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        minimumSize: Size(200, 0),
                      ),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 45),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a member?",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            // Navigate to the login screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => RegScreen()),
                            );
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF199A8E),
                            ),
                          ),
                        ),

                      ],
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
