import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_urls.dart';
import 'PasswordResetScreen.dart';
import 'status_code.dart';

class VerificationCodeEntryScreen extends StatefulWidget {
  final String email;
  final String verificationCode;
  final Future<void> Function() resendCodeCallback;

  VerificationCodeEntryScreen({
    required this.email,
    required this.verificationCode,
    required this.resendCodeCallback,
  });

  @override
  _VerificationCodeEntryScreenState createState() =>
      _VerificationCodeEntryScreenState();
}

class _VerificationCodeEntryScreenState
    extends State<VerificationCodeEntryScreen> {
  List<TextEditingController> codeControllers =
  List.generate(5, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(5, (_) => FocusNode());
  bool isResendingCode = false;
  bool isConfirmButtonEnabled = false;

  void _checkAllFieldsFilled() {
    bool allFieldsFilled =
    codeControllers.every((controller) => controller.text.isNotEmpty);
    setState(() {
      isConfirmButtonEnabled = allFieldsFilled;
    });
  }

  Future<void> verifyCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.verifyCodeUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'codeVerification': code,
        }),
      );

      if (response.statusCode == StatusCodes.ok) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetScreen(
              email: widget.email,
              verificationCode: widget.verificationCode,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code is incorrect or expired.'),
          ),
        );
      }
    } catch (error) {
      print('Error verifying code: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while verifying the code.'),
        ),
      );
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),
              Text(
                'Verification',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.07,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'assets/2.png',
                width: screenWidth * 0.9,
                height: screenHeight * 0.30,
                alignment: Alignment.center,
              ),
              Text(
                'A verification code has been sent to ${widget.email}. Please enter the code below:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.04,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return SizedBox(
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.15,
                      child: TextField(
                        controller: codeControllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                        ),
                        maxLength: 1,
                        onChanged: (value) {
                          _checkAllFieldsFilled();
                        },
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              ElevatedButton(
                onPressed: isConfirmButtonEnabled
                    ? () {
                  String enteredCode = codeControllers
                      .map((controller) => controller.text)
                      .join();
                  verifyCode(enteredCode);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF199A8E),
                  minimumSize: Size(screenWidth * 0.35, screenHeight * 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Did you fail to receive any code?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isResendingCode = true;
                  });
                  try {
                    await widget.resendCodeCallback();
                  } catch (error) {
                    print('Error resending code: $error');
                  } finally {
                    setState(() {
                      isResendingCode = false;
                    });
                  }
                },
                child: Text(
                  isResendingCode ? 'Resending Code...' : 'Resend Code',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Color(0xFF199A8E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
