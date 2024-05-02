import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'api_urls.dart';
import 'MedicalFolderRegistrationScreen.dart';
import 'loginScreen.dart';
import 'package:flutter/services.dart';



enum Gender { Female, Male }

class PersonalInformationRegistrationScreen extends StatefulWidget {
  @override
  _PersonalInformationRegistrationScreenState createState() =>
      _PersonalInformationRegistrationScreenState();

}

class _PersonalInformationRegistrationScreenState
    extends State<PersonalInformationRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  Gender _selectedGender = Gender.Female;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _registerPersonalInformation(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final responsePatient = await http.post(
          Uri.parse(ApiUrls.patientRegistration),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'first_name': _firstNameController.text.isNotEmpty
                ? _firstNameController.text
                : '/',
            'last_name': _lastNameController.text.isNotEmpty
                ? _lastNameController.text
                : '/',
            'email': _emailController.text.isNotEmpty
                ? _emailController.text
                : '/',
            'phone': _phoneController.text.isNotEmpty
                ? _phoneController.text
                : '/',
            'password': _passwordController.text.isNotEmpty
                ? _passwordController.text
                : '/',
            'role': 'patient',
            'address': _addressController.text.isNotEmpty
                ? _addressController.text
                : '/',
            'date_of_birth': _birthController.text.isNotEmpty
                ? _birthController.text
                : '/',
            'gender': _selectedGender == Gender.Female ? 'Female' : 'Male',
          }),
        );

        if (responsePatient.statusCode == 200) {
          _clearTextControllers();

          _showSuccessDialog(context, responsePatient);
        } else {
          _showSnackBar(context,
              'Patient registration failed. Please try again.');
        }
      } catch (error) {
        _showSnackBar(context, 'Error during registration. Please try again.');
      }
    }
  }

  void _clearTextControllers() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _addressController.clear();
    _birthController.clear();
    _confirmPasswordController.clear();
  }

  void _showSuccessDialog(BuildContext context, http.Response response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text(
            "Your Sign up was successful.\nYou can also register your medical folder! simply tap on 'Next'.",
            style: TextStyle(fontFamily: "Poppins"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => loginScreen()),
                );
              },
              child: Text(
                'Login',
                style: TextStyle(color: Color(0xFF199A8E)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicalFolderRegistrationScreen(
                      patientId: jsonDecode(response.body)['id'],
                    ),
                  ),
                );
              },
              child: Text(
                'Next',
                style: TextStyle(color: Color(0xFF199A8E)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white, // Start color
                Color(0xFFB0EFE9), // End color
              ],
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.04,
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                          Text(
                            'Welcome !',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize:
                              MediaQuery.of(context).size.width * 0.07,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.12),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Text(
                        'We are very excited to have you join',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize:
                          MediaQuery.of(context).size.width * 0.04,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Text(
                        'The family',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize:
                          MediaQuery.of(context).size.width * 0.04,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline,
                                color: Color(0xFF199A8E)),
                            labelText: 'First name',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _lastNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline,
                                color: Color(0xFF199A8E)),
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _birthController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF199A8E)),
                            labelText: 'Date Of Birth',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Icon(Icons.calendar_today, color: Color(0xFF199A8E)),
                            ),
                          ),
                          readOnly: true,
                          onTap: () {
                            _selectDate(context);
                          },
                        ),
                        DropdownButtonFormField<Gender>(
                          value: _selectedGender,
                          onChanged: (Gender? newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                            });
                          },
                          items: [
                            DropdownMenuItem<Gender>(
                              value: Gender.Female,
                              child: Text('Female'),
                            ),
                            DropdownMenuItem<Gender>(
                              value: Gender.Male,
                              child: Text('Male'),
                            ),
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.male,
                                color: Color(0xFF199A8E)),
                            labelText: 'Gender',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _addressController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on_outlined,
                                color: Color(0xFF199A8E)),
                            labelText: 'Address',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_outlined,
                                color: Color(0xFF199A8E)),
                            labelText: 'Phone number',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _emailController,

                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Color(0xFF199A8E)),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 7) {
                              return 'Password must be at least 7 characters long';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Color(0xFF199A8E)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color:Color(0xFF199A8E),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Color(0xFF199A8E)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xFF199A8E),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                                });
                              },
                            ),
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          color: Colors.white,
                          child: SizedBox(
                            child: ElevatedButton(
                              onPressed: () {
                                _registerPersonalInformation(context);
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  MediaQuery.of(context).size.width *
                                      0.06,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                    MediaQuery.of(context).size.height *
                                        0.02),
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.3,
                                    0),
                                backgroundColor: Color(0xFF199A8E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
