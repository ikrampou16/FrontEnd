import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'loginScreen.dart';
import 'api_urls.dart';
import 'VerificationCodeEntryScreen.dart';
import 'status_code.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryScreenState createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    } else {
      return 'Please enter your email';
    }
    return null;
  }

  Future<void> _recoverPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      try {
        setState(() {
          _isLoading = true;
        });

        final response = await http.post(
          Uri.parse(ApiUrls.passwordRecoveryUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == StatusCodes.ok) {
          final responseData = json.decode(response.body);
          final verificationCode = responseData['verificationCode'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification code sent to your email.'),
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationCodeEntryScreen(
                email: email,
                verificationCode: verificationCode,
                resendCodeCallback: () async {
                  await _recoverPassword(context);
                },
              ),
            ),
          );
        } else if (response.statusCode == StatusCodes.notFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email not registered. Please enter a valid email address.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        print('Error during password recovery: $error');
      }
    }
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
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/1.png',
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.25,
                  alignment: Alignment.center,
                ),
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.08,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Don’t worry. It happens to the best of us.\nType your email to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.03,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextFormField(
                  controller: _emailController,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF199A8E)),
                    labelText: 'Enter your email',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      borderSide: BorderSide(color: Color(0xFF199A8E)),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                    await _recoverPassword(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF199A8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.025),
                    minimumSize: Size(screenWidth * 0.4, 0),
                  ),
                  child: Text(
                    'Send',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                if (_isLoading) CircularProgressIndicator(),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Remember your password?',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => loginScreen()),
                      );
                    },
                    child: Text(
                      'Log In',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05,
                        color: Color(0xFF199A8E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
