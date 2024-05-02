import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData(widget.patientId);
    _medicalFolderDataFuture = _fetchMedicalFolderData(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Patient Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFB0EFE9)],
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
        _buildToggleButtons(), // Include the toggle buttons here
        SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: FutureBuilder(
              future: _showPersonalInfo ? _profileDataFuture : _medicalFolderDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  // Handle error here
                  print('Error fetching data: ${snapshot.error}');
                  // Return an empty map or null to prevent the UI from crashing
                  return _buildMedicalFolderInfo({});
                } else {
                  final data = snapshot.data as Map<String, dynamic>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showPersonalInfo)
                        _buildPersonalInfoSection(data),
                      if (!_showPersonalInfo)
                        _buildMedicalFolderInfo(data),
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
      };
    }
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
            ),
          ),
        ),
        _buildProfileField('Diabetes Type', '${data['diabetes_type']}', Icons.medical_services_outlined, true),
        _buildProfileField('Diabetes Diagnosis Date', '${data['diabetes_history']}', Icons.history, true),
        _buildProfileField('Height', '${data['height']}', Icons.height, true),
        _buildProfileField('Weight', '${data['weight']}', Icons.fitness_center, true),
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
            backgroundColor: _showPersonalInfo ? Color(0xFFB0EFE9) : Colors.white,
          ),
          child: Text(
            'Personal Info',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
            backgroundColor: !_showPersonalInfo ? Color(0xFFB0EFE9) : Colors.white,
          ),
          child: Text(
            'Medical Folder',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
            ),
          ),
        ),
        _buildProfileField('Name', '${data['first_name']} ${data['last_name']}', Icons.person_outline, false),
        _buildProfileField('Gender', '${data['gender']}', Icons.person_outline, false),
        _buildProfileField('Date Of Birth', '${data['date_of_birth']}', Icons.date_range_outlined, false),
        _buildProfileField('Address', '${data['address']}', Icons.location_on_outlined, false),
        _buildProfileField('Email', '${data['email']}', Icons.email_outlined, false),
        _buildProfileField('Phone Number', '${data['phone']}', Icons.phone_outlined, false),
      ],
    );
  }

  Widget _buildProfileField(String label, String value, IconData iconData, bool isMedicalField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            IconTheme(
              data: IconThemeData(
                color: Colors.teal,
                size: 20,
              ),
              child: Icon(iconData),
            ),
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
            if (value.isNotEmpty)
              IconButton(
                onPressed: () {
                  if (isMedicalField) {
                    _showMedicalFolderEditDialog(label, value);
                  } else {
                    _showEditDialog(label, value);
                  }
                },
                icon: Icon(Icons.edit_outlined),
                color: Colors.teal,
              ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          value.isNotEmpty ? value : 'Empty',
          style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
        ),
        Divider(color: Colors.grey),
      ],
    );
  }

  void _showEditDialog(String label, String currentValue) {
    TextEditingController textEditingController = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: 'Enter new $label',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newValue = textEditingController.text;
                if (label.isNotEmpty && newValue.isNotEmpty) {
                  String lowercaseLabel = label.toLowerCase();
                  Navigator.of(context).pop();
                  String requestBody = jsonEncode({'field': lowercaseLabel, 'value': newValue});
                  try {
                    final response = await http.put(
                      Uri.parse(ApiUrls.updateProfileUrl(widget.patientId)),
                      headers: {'Content-Type': 'application/json'},
                      body: requestBody,
                    );
                    if (response.statusCode == 200) {
                      // Call _updateProfileData after successful update
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
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showMedicalFolderEditDialog(String label, String currentValue) async {
    // Check if the field being edited is a date field
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
          currentValue = pickedDate.toIso8601String().substring(0, 10); // Update currentValue with the new date
        });
      } else {
        return; // User canceled, do nothing
      }
    }

    // For other fields, show a text field or dropdown
    TextEditingController textEditingController = TextEditingController(text: currentValue);
    String? selectedValue = null;
    bool isDiabetesTypeField = label == 'Diabetes Type';
    bool showUnits = label != 'Height' && label != 'Weight';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $label'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDiabetesTypeField)
                    TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Enter new $label',
                      ),
                    ),
                  if (isDiabetesTypeField)
                    DropdownButton<String?>(
                      value: selectedValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                      items: <String?>[null, 'Type 1', 'Type 2'].map((String? value) {
                        return DropdownMenuItem<String?>(
                          value: value,
                          child: Text(value ?? 'None'),
                        );
                      }).toList(),
                    ),
                  if (!showUnits)
                    Text(
                      '(${label == 'Height' ? 'cm' : 'Kg'})',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String newValue = isDiabetesTypeField ? selectedValue ?? '' : textEditingController.text;
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
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<Map<String, dynamic>> _fetchProfileData(int patientId) async {
    try {
      final profileResponse = await http.get(
        Uri.parse(ApiUrls.patientProfileUrl(patientId)),
      );

      if (profileResponse.statusCode == 200) {
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

      if (medicalFolderResponse.statusCode == 200) {
        final medicalFolderData = jsonDecode(medicalFolderResponse.body);

        if (medicalFolderData['status'] == true) {
          return medicalFolderData['information'];
        } else {
          // Initialize with null values if medical folder is not found
          return {
            'diabetes_type': null,
            'diabetes_history': null,
            'height': null,
            'weight': null,
          };
        }
      } else if (medicalFolderResponse.statusCode == 404) {
        // Initialize with null values if medical folder is not found
        return {
          'diabetes_type': null,
          'diabetes_history': null,
          'height': null,
          'weight': null,
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
}