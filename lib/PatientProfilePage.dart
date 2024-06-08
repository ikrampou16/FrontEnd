import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'status_code.dart';
import 'api_urls.dart';
import 'dart:convert';

class PatientProfilePage extends StatefulWidget {
  final int patientId;

  PatientProfilePage({required this.patientId});

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  late Future<Map<String, dynamic>> _profileDataFuture;
  late Future<Map<String, dynamic>> _medicalFolderDataFuture;
  bool _showPersonalInfo = true;
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  ValueNotifier<bool> _isCurrentPasswordVisible = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isNewPasswordVisible = ValueNotifier<bool>(false);
  List<String?> areaOptions = [null, 'Northeast', 'Northwest', 'Southeast', 'Southwest', 'Center'];

  List<String> _getDropdownItems(String label) {
    if (label == 'Diabetes Type') {
      return ['Type 1', 'Type 2'];
    } else if (label == 'Smoker') {
      return ['Yes', 'No'];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData(widget.patientId);
    _medicalFolderDataFuture = _fetchMedicalFolderData(widget.patientId);
  }
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    _isCurrentPasswordVisible.dispose();
    _isNewPasswordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Patient Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleButtons(),
        SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: FutureBuilder(
              future: _showPersonalInfo ? _profileDataFuture : _medicalFolderDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                } else if (snapshot.hasError) {
                  print('Error fetching data: ${snapshot.error}');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showErrorSnackBar('Error fetching data: ${snapshot.error}');
                  });
                  return _buildMedicalFolderInfo({});
                } else {
                  final data = snapshot.data as Map<String, dynamic>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showPersonalInfo) _buildPersonalInfoSection(data),
                      if (!_showPersonalInfo) _buildMedicalFolderInfo(data),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildMedicalFolderInfo(Map<String, dynamic> data) {
    if (data.isEmpty) {
      data = {
        'diabetes_type': null,
        'diabetes_history': null,
        'height': null,
        'weight': null,
        'is_smoke': null,
        'area': null
      };
    }

    double? height = data['height'] != null ? double.tryParse(data['height'].toString()) : null;
    double? weight = data['weight'] != null ? double.tryParse(data['weight'].toString()) : null;
    double? bmi = (height != null && weight != null) ? (weight / (height * height) * 10000) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Medical Folder Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
              color: Colors.teal,
            ),
          ),
        ),
        _buildProfileField('Diabetes Type', '${data['diabetes_type']}', Icons.medical_services_outlined, true),
        _buildProfileField('Diabetes Diagnosis Date', '${data['diabetes_history']}', Icons.history_outlined, true),
        _buildProfileField('Height', '${data['height']}', Icons.height_outlined, true),
        _buildProfileField('Weight', '${data['weight']}', Icons.fitness_center_outlined, true),
        _buildProfileField('Smoker', '${data['is_smoke']}', Icons.smoking_rooms_outlined, true),
        _buildProfileField('Area', '${data['area']}', Icons.area_chart_outlined, true),
        if (bmi != null)
          _buildProfileField('BMI (Body Mass Index)', bmi.toStringAsFixed(2), Icons.monitor_weight_outlined, false),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showPersonalInfo = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _showPersonalInfo ? Colors.teal : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'Personal Info',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: _showPersonalInfo ? Colors.white : Colors.teal,
            ),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showPersonalInfo = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: !_showPersonalInfo ? Colors.teal : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'Medical Folder',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: !_showPersonalInfo ? Colors.white : Colors.teal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
              color: Colors.teal,
            ),
          ),
        ),
        _buildProfileField('Name', '${data['first_name']} ${data['last_name']}', Icons.person_outline, false),
        _buildProfileField('Gender', '${data['gender']}', Icons.male_outlined, false),
        _buildProfileField('Date Of Birth', '${data['date_of_birth']}', Icons.date_range_outlined, false),
        _buildProfileField('Address', '${data['address']}', Icons.location_on_outlined, false),
        _buildProfileField('Email', '${data['email']}', Icons.email_outlined, false),
        _buildProfileField('Password', '********', Icons.lock_outline, false),
        _buildProfileField('Phone Number', '${data['phone']}', Icons.phone_outlined, false),
      ],
    );
  }

  Widget _buildProfileField(String label, String value, IconData iconData, bool isMedicalField) {
    bool isBMIField = label == 'BMI';

    // Function to check if the provided value is a valid phone number
    bool isValidPhoneNumber(String phoneNumber) {
      if (phoneNumber.startsWith('0') && phoneNumber.length == 10) {
        // Check if all characters are digits
        return phoneNumber.substring(1).contains(RegExp(r'^[0-9]*$'));
      }
      return false;
    }

    // Display the phone number with leading '0' if it starts with '0'
    String displayedPhoneNumber = value;
    if (label == 'Phone Number' && value.isNotEmpty && value[0] == '0') {
      displayedPhoneNumber = '$value';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            Icon(iconData, color: Colors.teal, size: 24),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
            Spacer(),
            if (value.isNotEmpty && !isBMIField) // Exclude edit icon for BMI field
              IconButton(
                onPressed: () {
                  if (isMedicalField) {
                    _showMedicalFolderEditDialog(label, value);
                  } else {
                    if (label.toLowerCase() == 'password') {
                      _showModifyPasswordDialog();
                    } else {
                      _showEditDialog(label, value);
                    }
                  }
                },
                icon: Icon(Icons.edit_outlined, color: Colors.teal),
              ),
          ],
        ),
        SizedBox(height: 5),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: displayedPhoneNumber, // Display the formatted phone number
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(0),
          ),
          style: TextStyle(fontSize: 17, fontFamily: "Poppins"),
          keyboardType: label == 'Phone Number'? TextInputType.number : TextInputType.text, // Restrict to numbers for phone number field
          inputFormatters: label == 'Phone Number'? [FilteringTextInputFormatter.digitsOnly] : null, // Allow only digits for phone number
        ),
        // Display error message if the phone number format is invalid
        if (label == 'Phone Number' && value.isNotEmpty && !isValidPhoneNumber(value))
          Text(
            'Invalid phone number',
            style: TextStyle(color: Colors.red),
          ),
        Divider(color: Colors.grey),
      ],
    );
  }
  Future<Map<String, dynamic>> _fetchProfileData(int patientId) async {
    try {
      final profileResponse = await http.get(
        Uri.parse(ApiUrls.patientProfileUrl(patientId)),
      );

      if (profileResponse.statusCode == StatusCodes.ok) {
        return jsonDecode(profileResponse.body);
      } else {
        throw Exception('Failed to fetch patient profile: ${profileResponse.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching profile data: $error');
    }
  }

  Future<Map<String, dynamic>> _fetchMedicalFolderData(int patientId) async {
    try {
      final medicalFolderResponse = await http.get(
        Uri.parse(ApiUrls.medicalFolderUrl(patientId)),
      );

      if (medicalFolderResponse.statusCode == StatusCodes.ok) {
        final medicalFolderData = jsonDecode(medicalFolderResponse.body);

        if (medicalFolderData['status'] == true) {
          return medicalFolderData['information'];
        } else {
          return {
            'diabetes_type': null,
            'diabetes_history': null,
            'height': null,
            'weight': null,
            'is_smoke':null,
            'area':null
          };
        }
      } else if (medicalFolderResponse.statusCode == StatusCodes.notFound) {
        return {
          'diabetes_type': null,
          'diabetes_history': null,
          'height': null,
          'weight': null,
          'is_smoke':null,
          'area':null
        };
      } else {
        throw Exception('Failed to fetch medical folder: ${medicalFolderResponse.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching medical folder data: $error');
    }
  }


  Future<void> _updateProfileData() async {
    try {
      final updatedData = await _fetchProfileData(widget.patientId);
      setState(() {
        _profileDataFuture = Future.value(updatedData);
      });
    } catch (error) {
      print('Error updating profile data: $error');
    }
  }

  Future<void> _updateMedicalFolderData() async {
    try {
      final updatedData = await _fetchMedicalFolderData(widget.patientId);
      setState(() {
        _medicalFolderDataFuture = Future.value(updatedData);
      });
    } catch (error) {
      print('Error updating medical folder data: $error');
    }
  }

  Future<void> _updatePassword(String currentPassword, String newPassword) async {
    try {
      var response = await http.put(
        Uri.parse('${ApiUrls.baseUrl}/patients/${widget.patientId}/change_password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == StatusCodes.ok) {
        _showSuccessSnackBar('Password updated successfully');
      } else {
        _showErrorSnackBar('Failed to update password: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackBar('Error updating password: $error');
    }
  }

  void _showEditDialog(String label, String currentValue) async {
    if (label == 'Date Of Birth') {
      DateTime? selectedDate = currentValue.isNotEmpty ? DateTime.tryParse(currentValue) : null;

      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        setState(() {
          currentValue = pickedDate.toIso8601String().substring(0, 10);
        });
      } else {
        return;
      }
    }

    TextEditingController textEditingController = TextEditingController(text: currentValue);
    String? selectedValue = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit $label',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label == 'Gender')
                    DropdownButton<String?>(
                      value: selectedValue ?? currentValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                      items: <String?>['Male', 'Female'].map((String? value) {
                        return DropdownMenuItem<String?>(
                          value: value,
                          child: Text(value ?? 'None'),
                        );
                      }).toList(),
                    ),
                  if (label != 'Gender')
                    TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Enter new $label',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontFamily: "Poppins", color: Colors.teal),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newValue = label == 'Gender' ? (selectedValue ?? '') : textEditingController.text;

                    if (label.isNotEmpty && newValue.isNotEmpty) {
                      Navigator.of(context).pop();

                      String lowercaseLabel = label.toLowerCase();
                      String requestBody = jsonEncode({'field': lowercaseLabel, 'value': newValue});
                      try {
                        final response = await http.put(
                          Uri.parse(ApiUrls.updateProfileUrl(widget.patientId)),
                          headers: {'Content-Type': 'application/json'},
                          body: requestBody,
                        );
                        if (response.statusCode == StatusCodes.ok) {
                          await _updateProfileData();
                        } else {
                          print('Error updating profile: ${response.statusCode}');
                        }
                      } catch (error) {
                        print('Network error: $error');
                      }
                    } else {
                      print('Field or value is empty');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontFamily: "Poppins"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMedicalFolderEditDialog(String label, String currentValue) async {
    if (label == 'Diabetes Diagnosis Date') {
      DateTime? selectedDate = currentValue.isNotEmpty ? DateTime.tryParse(currentValue) : null;

      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        setState(() {
          currentValue = pickedDate.toIso8601String().substring(0, 10);
        });
      } else {
        return;
      }
    }

    TextEditingController textEditingController = TextEditingController(text: currentValue);
    String? selectedValue = null;
    bool isDiabetesTypeField = label == 'Diabetes Type';
    bool isSmokerField = label == 'Smoker';
    bool isAreaField = label == 'Area';
    bool showUnits = label != 'Height' && label != 'Weight';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit $label',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isAreaField && !isDiabetesTypeField && !isSmokerField)
                    TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Enter new $label',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                  if (isAreaField)
                    DropdownButton<String?>(
                      value: selectedValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                      items: areaOptions.map((String? value) {
                        return DropdownMenuItem<String?>(
                          value: value,
                          child: Text(value ?? 'None'),
                        );
                      }).toList(),
                    ),
                  if (!showUnits)
                    Text(
                      '(${label == 'Height' ? 'cm' : 'Kg'})',
                      style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                    ),
                  if (isSmokerField || isDiabetesTypeField)
                    DropdownButton<String?>(
                      value: selectedValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                      items: <String?>[null, ..._getDropdownItems(label)].map((String? value) {
                        return DropdownMenuItem<String?>(
                          value: value,
                          child: Text(value ?? 'None'),
                        );
                      }).toList(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontFamily: "Poppins", color: Colors.teal),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newValue;
                    if (isDiabetesTypeField || isSmokerField || isAreaField) {
                      newValue = selectedValue ?? '';
                    } else {
                      newValue = textEditingController.text;
                    }

                    if (label.isNotEmpty && newValue.isNotEmpty) {
                      String lowercaseLabel = label.toLowerCase();
                      Navigator.of(context).pop();
                      String requestBody = jsonEncode({'field': lowercaseLabel, 'value': newValue});
                      try {
                        final response = await http.put(
                          Uri.parse(ApiUrls.updateMedicalFolderUrl(widget.patientId)),
                          headers: {'Content-Type': 'application/json'},
                          body: requestBody,
                        );
                        if (response.statusCode == 200) {
                          await _updateMedicalFolderData();
                        } else {
                          print('Error updating medical folder: ${response.statusCode}');
                        }
                      } catch (error) {
                        print('Network error: $error');
                      }
                    } else {
                      print('Field or value is empty');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontFamily: "Poppins"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showModifyPasswordDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Change Password',
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _isCurrentPasswordVisible,
                builder: (context, isVisible, child) {
                  return TextField(
                    controller: currentPasswordController,
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _isCurrentPasswordVisible.value = !isVisible;
                        },
                      ),
                    ),
                    style: TextStyle(fontFamily: "Poppins"),
                  );
                },
              ),
              SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _isNewPasswordVisible,
                builder: (context, isVisible, child) {
                  return TextField(
                    controller: newPasswordController,
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _isNewPasswordVisible.value = !isVisible;
                        },
                      ),
                    ),
                    style: TextStyle(fontFamily: "Poppins"),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontFamily: "Poppins", color: Colors.teal),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;

                if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                  // Update password
                  String requestBody = jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword});

                  try {
                    final response = await http.put(
                      Uri.parse(ApiUrls.modifyPasswordUrl(widget.patientId)),
                      headers: {'Content-Type': 'application/json'},
                      body: requestBody,
                    );
                    if (response.statusCode == 200) {
                      _showSuccessSnackBar('Password updated successfully');
                      Navigator.of(context).pop(); // Close the dialog after success
                    } else if (response.statusCode == 401) {
                      _showErrorSnackBar('Incorrect current password');
                    } else {
                      _showErrorSnackBar('Error updating password: ${response.statusCode}');
                    }
                  } catch (error) {
                    _showErrorSnackBar('Network error: $error');
                  }
                } else {
                  _showErrorSnackBar('Password fields cannot be empty');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(fontFamily: "Poppins"),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: "Poppins"),
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: "Poppins"),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
