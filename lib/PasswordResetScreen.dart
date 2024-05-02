import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_urls.dart';
import 'loginScreen.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  PasswordResetScreen({required this.email, required this.verificationCode});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFB0EFE9)],
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),
              Text(
                'Password Reset',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.08,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'assets/lock.jpg',
                width: screenWidth * 0.65,
                height: screenHeight * 0.2,
                alignment: Alignment.center,
              ),
              Text(
                'Enter your new password ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.04,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText1,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText1 ? Icons.visibility_off : Icons.visibility,
                            color: Color(0xFF199A8E),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText1 = !_obscureText1;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureText2,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText2 ? Icons.visibility_off : Icons.visibility,
                            color: Color(0xFF199A8E),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText2 = !_obscureText2;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final response = await http.post(
                        Uri.parse(ApiUrls.passwordResetUrl),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'email': widget.email,
                          'newPassword': _passwordController.text,
                          'codeVerification': widget.verificationCode,
                        }),
                      );

                      if (response.statusCode == 200) {
                        _showSuccessDialog();
                      } else {
                        _showErrorSnackBar();
                      }
                    } catch (error) {
                      _showErrorSnackBar();
                      print('Error during password reset: $error');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF199A8E),
                  minimumSize: Size(screenWidth * 0.5, 0),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(
              'Success',
              style: TextStyle(fontFamily: "Poppins", color: Color(0xFF199A8E)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password reset successful. You can now log in with your new password.',
                  style: TextStyle(fontFamily: "Poppins", fontSize: MediaQuery.of(context).size.width * 0.04),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => loginScreen()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Color(0xFF199A8E),
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset failed. Please try again.'),
      ),
    );
  }
}
