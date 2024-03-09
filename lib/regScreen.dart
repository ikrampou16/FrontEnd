import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'loginScreen.dart';

class RegScreen extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController adressController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController diabeteController = TextEditingController();
  final TextEditingController diabHisController = TextEditingController();
  final TextEditingController dkaHisController = TextEditingController();




  String errorMessage = '';

  Future<void> registerPatient(BuildContext context) async {
    // Check for empty fields
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      errorMessage = 'Please fill in all fields.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check if passwords match
    if (passwordController.text.toLowerCase() != confirmPasswordController.text.toLowerCase()) {
      errorMessage = 'Passwords do not match. Please enter the same password in both fields.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Proceed with registration
    try {
      final responsePatient = await http.post(
        Uri.parse('http://192.168.89.226:3000/api/patient'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'password': passwordController.text,
          'role': 'patient',
        }),
      );

      if (responsePatient.statusCode == 200) {
        // Patient registration successful, proceed with medical folder registration
        await registerMedicalFolder(context, jsonDecode(responsePatient.body)['id']);
      } else {
        // Handle patient registration failure
        print('Patient registration failed: ${responsePatient.statusCode} - ${responsePatient.body}');
        errorMessage = 'Patient registration failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      // Handle network or other errors
      print('Error during registration: $error');
      errorMessage = 'Error during registration. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );
    }

    // Show success dialog regardless of patient registration status
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('You have successfully signed up!'),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog and navigate to the login screen
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => loginScreen()),
                  );
                },
                child: Text('Log in'),
              ),
            ],
          );
        }
    );
  }
  Future<void> registerMedicalFolder(BuildContext context, int patientId) async {
    try {
      final responseMedicalFolder = await http.post(
        Uri.parse('http://192.168.89.226:3000/api/medicalfolder/$patientId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'diabetes_type': diabeteController.text,
          'diabetes_history': diabHisController.text,
          'dka_history': dkaHisController.text,
          'address': adressController.text,
          'age': ageController.text,
          'gender': genderController.text,
          'weight': weightController.text,
          'height': heightController.text,
        }),
      );

      if (responseMedicalFolder.statusCode != 200) {
        // Handle medical folder registration failure
        print('Medical folder registration failed: ${responseMedicalFolder.statusCode} - ${responseMedicalFolder.body}');
        errorMessage = 'Medical folder registration failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      // Handle network or other errors
      print('Error during medical folder registration: $error');
      errorMessage = 'Error during medical folder registration. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white, // Start color
                    Color(0xFFB0EFE9), // End color
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Text(
                      'Welcome !',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        color: Colors.black, // Adjust text color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20), // Adjust the height as needed
                    Text(
                      'We are very excited to have you join',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'The family',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 23,
                        color: Color(0xFF199A8E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Color(0xFF199A8E)),
                        labelText: 'First name',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF199A8E), // Set the border color to green
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Color(0xFF199A8E)),
                        labelText: 'Last Name',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF199A8E), // Set the border color to green
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Color(0xFF199A8E)),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF199A8E), // Set the border color to green
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF199A8E)),
                        labelText: 'Phone number',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF199A8E), // Set the border color to green
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF199A8E)),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF199A8E), // Set the border color to green
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF199A8E)),
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF199A8E), // Set the border color to green
                          ),
                        ),
                      ),
                    ),

                       TextField(
                         controller: adressController,
                         decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_pin, color: Color(0xFF199A8E)),
                         labelText: 'Adress',
                      labelStyle: TextStyle(
                     fontFamily: 'Poppins',
                         color: Colors.black,
                         ), focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                                color: Color(0xFF199A8E), // Set the border color to green
                             ),
                        ),
                            ),
                               ),
                         TextField(
                          controller: ageController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF199A8E)),
                            labelText: 'Age',
                            labelStyle: TextStyle(
                           fontFamily: 'Poppins',
                             color: Colors.black,
                            ), focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                                 color: Color(0xFF199A8E), // Set the border color to green
                                  ),
                                    ),
                          ),
                                  ),
                             TextField(
                              controller: genderController,
                             decoration: InputDecoration(
                               prefixIcon: Icon(Icons.male, color: Color(0xFF199A8E)),
                                   labelText: 'Gender',
                                labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                               color: Colors.black,
                                ), focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                   color: Color(0xFF199A8E), // Set the border color to green
                                       ),
                               ),
                                   ),
                                       ),
                               TextField(
                                 controller: weightController,
                                      decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.scale, color: Color(0xFF199A8E)),
                                   labelText: 'Weight',
                                 labelStyle: TextStyle(
                               fontFamily: 'Poppins',
                                   color: Colors.black,
                                  ), focusedBorder: UnderlineInputBorder(
                             borderSide: BorderSide(
                                       color: Color(0xFF199A8E), // Set the border color to green
                                   ),
                                              ),
                                 ),
                                 ),
                                     TextField(
                                      controller: heightController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.horizontal_rule, color: Color(0xFF199A8E)),
                                   labelText: 'Height',
                                       labelStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                        color: Colors.black,
                                        ), focusedBorder: UnderlineInputBorder(
                                                   borderSide: BorderSide(
                                        color: Color(0xFF199A8E), // Set the border color to green
                                        ),
                                  ),
                                        ),
                                       ),
                                    TextField(
                                     controller: diabeteController,
                                             decoration: InputDecoration(
                                     prefixIcon: Icon(Icons.sick, color: Color(0xFF199A8E)),
                                           labelText: 'Diabetes Type',
                                      labelStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                      color: Colors.black,
                                            ), focusedBorder: UnderlineInputBorder(
                                     borderSide: BorderSide(
                                       color: Color(0xFF199A8E), // Set the border color to green
                                      ),
                                           ),
                                       ),
                                      ),
                                      TextField(
                                        controller: diabHisController,
                                       decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.history, color: Color(0xFF199A8E)),
                                        labelText: 'Diabetes History',
                                      labelStyle: TextStyle(
                                         fontFamily: 'Poppins',
                                       color: Colors.black,
                                              ),focusedBorder: UnderlineInputBorder(
                                         borderSide: BorderSide(
                                           color: Color(0xFF199A8E), // Set the border color to green
                                         ),
                                       ),
                                       ),
                                      ),
                                               TextField(
                                      controller: dkaHisController,
                                       decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.history, color: Color(0xFF199A8E)),
                                          labelText: 'DKA History',
                                           labelStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                           color: Colors.black,
                                           ),focusedBorder: UnderlineInputBorder(
                                         borderSide: BorderSide(
                                           color: Color(0xFF199A8E), // Set the border color to green
                                         ),
                                       ),
                                       ),
                                               ),
                    const SizedBox(height: 15),
                    Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white, // Start color
                            Color(0xFFB0EFE9), // End color
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          registerPatient(context); // Pass the context to the method
                          if (errorMessage.isNotEmpty) {
                            // Show error message to the user
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
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
                          'Sign up',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
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
                              MaterialPageRoute(builder: (context) => loginScreen()),
                            );
                          },
                          child: Text(
                            "Log in",
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
            ),
          ],
        ),
      ),
    );
  }
}