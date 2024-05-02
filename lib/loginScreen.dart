import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'PasswordRecoveryScreen.dart';
import 'PersonalInformationRegistrationScreen.dart';
import 'FirstPage.dart';
import 'api_urls.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  bool _isLoading = false;
  bool _obscureText = true;

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

  Future<void> _loginUser(BuildContext context) async {
    setState(() {
      _isLoading = true; // Start loading indicator
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final response = await http.post(
          Uri.parse(ApiUrls.loginUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];

          print('Received token: $token');

          final decodedToken = jsonDecode(utf8.decode(base64.decode(base64.normalize(token.split('.')[1]))));
          final patientId = decodedToken['id'];
          print('Patient ID: $patientId');

          // Fetch user information to get the first name
          final userResponse = await http.get(
            Uri.parse('${ApiUrls.userDetailsUrl}/$patientId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            final token = responseData['token'];
            print('Received token: $token');

            final decodedToken = jsonDecode(utf8.decode(base64.decode(base64.normalize(token.split('.')[1]))));
            final patientId = decodedToken['id'];
            print('Patient ID: $patientId');

            // Store token in SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn', true);
            prefs.setString('token', token); // Store the received token
            print('Token stored in SharedPreferences: $token');

            // Fetch user information to get the first name
            final userResponse = await http.get(
              Uri.parse('${ApiUrls.userDetailsUrl}/$patientId'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );

            if (userResponse.statusCode == 200) {
              final userData = jsonDecode(userResponse.body);
              final firstName = userData['first_name'];
              final prefs = await SharedPreferences.getInstance();
              prefs.setInt('patientId', patientId);
              print('Patient ID stored in SharedPreferences: $patientId');

              final storedPatientId = prefs.getInt('patientId');
              print('Patient ID retrieved from SharedPreferences: $storedPatientId');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FirstPage(firstName: firstName, patientId: patientId),
                ),
              );
            } else {
              print('Failed to fetch user information: ${userResponse.statusCode}');
            }
          }
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incorrect email or password. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          print('Login failed: ${response.statusCode} - ${response.body}');
        }
      } catch (error) {
        print('Error during login: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFB0EFE9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Text(
                    'Hello Again!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Image.asset(
                    'assets/login.png',
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome back, you\'ve been missed!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 70),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          onChanged: (value) {
                            email = value;
                          },
                          validator: _validateEmail,
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
                              borderSide: BorderSide(color: Color(0xFF199A8E)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          obscureText: _obscureText,
                          onChanged: (value) {
                            password = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Color(0xFF199A8E)),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFF199A8E),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Color(0xFF199A8E)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
                              );
                            },
                            child: Text(
                              'Recovery Password',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.035,
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () async {
                            await _loginUser(context);
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
                              fontSize: MediaQuery.of(context).size.width * 0.045,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not a member?",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.04,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PersonalInformationRegistrationScreen()),
                                );
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}