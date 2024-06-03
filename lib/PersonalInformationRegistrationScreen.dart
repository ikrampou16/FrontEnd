import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:untitled3/WelcomeScreen.dart';
import 'dart:convert';
import 'api_urls.dart';
import 'MedicalFolderRegistrationScreen.dart';
import 'loginScreen.dart';
import 'package:flutter/services.dart';
import 'status_code.dart';


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
  bool _acceptedTerms = false;
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

        if (responsePatient.statusCode == StatusCodes.ok) {
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

  void _showConsentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Block back button
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Terms of Use"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "We require your permission to securely store and utilize your information to enhance your experience and provide personalized services.",
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value!;
                            });
                          },
                        ),
                        Text("I accept the terms"),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomeScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Decline',
                      style: TextStyle(color: Color(0xFF199A8E)),
                    ),
                  ),
                  TextButton(
                    onPressed: _acceptedTerms
                        ? () {
                      Navigator.pop(context); // Close dialog
                    }
                        : null,
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        color: _acceptedTerms ? Color(0xFF199A8E) : Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _showConsentDialog();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeMessage(),
              SizedBox(height: 16),
              _buildFormFields(context),
              SizedBox(height: 16),
              _buildSignUpButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          'Please fill in your details below:',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          decoration: InputDecoration(labelText: 'First Name',
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF199A8E)),
          ),

          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your first name';
            }
            return null;
          },
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
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF199A8E)),
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
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your date of birth';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_month_outlined, color: Color(0xFF199A8E)),
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
              child: Icon(Icons.calendar_month_outlined, color: Color(0xFF199A8E)),
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
          validator: (value) {
            if (value == null) {
              return 'Please select your gender';
            }
            return null;
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
            prefixIcon: Icon(Icons.male, color: Color(0xFF199A8E)),
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
            prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF199A8E)),
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
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF199A8E)),
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
            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF199A8E)),
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
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF199A8E)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Color(0xFF199A8E),
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
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF199A8E)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Color(0xFF199A8E),
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
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
      ],
    );
  }


  Widget _buildSignUpButton(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
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
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Color(0xFF199A8E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}