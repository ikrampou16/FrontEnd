import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'api_urls.dart';
import 'loginScreen.dart';

class MedicalFolderRegistrationScreen extends StatefulWidget {
  final int patientId;

  MedicalFolderRegistrationScreen({required this.patientId});

  @override
  _MedicalFolderRegistrationScreenState createState() =>
      _MedicalFolderRegistrationScreenState();
}

class _MedicalFolderRegistrationScreenState
    extends State<MedicalFolderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController diabeteController = TextEditingController();
  final TextEditingController diabHisController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController doctorFirstNameController = TextEditingController();
  final TextEditingController doctorLastNameController = TextEditingController();
  final TextEditingController acetoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool selectDoctorFromList = true;
  bool showDKHFields = false;
  String errorMessage = '';
  String? dkaOrderValue;
  List<Map<String, dynamic>> doctorsList = [];
  List<Map<String, dynamic>> savedDkaHistoryList = [];

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> fetchDoctors(BuildContext context) async {
    try {
      final response = await http.get(
          Uri.parse(ApiUrls.doctorsNameUrl));

      if (response.statusCode == 200) {
        final List<dynamic> decodedData =
        json.decode(response.body)['doctors'];
        setState(() {
          doctorsList = decodedData.cast<Map<String, dynamic>>().toList();
        });
      } else {
        throw Exception('Failed to fetch doctors');
      }
    } catch (error) {
      print('Error fetching doctors: $error');
      _showErrorSnackBar('Failed to fetch doctors. Please try again.');
    }
  }

  Future<void> registerMedicalFolder(BuildContext context) async {
    try {
      int? selectedDoctorId;
      String? doctorFirstName;
      String? doctorLastName;

      if (selectDoctorFromList) {
        selectedDoctorId = int.tryParse(doctorFirstNameController.text);
      } else {
        doctorFirstName = doctorFirstNameController.text;
        doctorLastName = doctorLastNameController.text;
      }
      if (widget.patientId == null) {
        print('Error: Invalid patient ID');
        showErrorSnackBar('Invalid patient ID. Please try again.');
        return;
      }
      int? idFolder;
      if (!selectDoctorFromList) {
        int? currentPatientId = widget.patientId;
        print('Current Patient ID: $currentPatientId');
        final responseCreateDoctor = await http.post(
          Uri.parse('${ApiUrls.optionalDoctorUrl}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'first_name': doctorFirstName,
            'last_name': doctorLastName,
            'optional': true,
          }),
        );
        if (responseCreateDoctor.statusCode != 200) {
          print('Doctor creation failed: ${responseCreateDoctor.statusCode} - ${responseCreateDoctor.body}');
          showErrorSnackBar('Doctor creation failed. Please try again.');
          return;
        }

        final Map<String, dynamic> createdDoctor = json.decode(responseCreateDoctor.body);
        selectedDoctorId = createdDoctor['id'];
        print('Patient ID first : $currentPatientId');

        final responseMedicalFolderWithNewDoctor = await http.post(
          Uri.parse('${ApiUrls.medicalFolderUrlPrefix}$currentPatientId'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'diabetes_type': diabeteController.text.isNotEmpty ? diabeteController.text : null,
            'diabetes_history': diabHisController.text.isNotEmpty ? diabHisController.text : null,
            'weight': weightController.text.isNotEmpty ? weightController.text : null,
            'height': heightController.text.isNotEmpty ? heightController.text : null,
            'id_doctor': selectedDoctorId,
          }),
        );
        if (responseMedicalFolderWithNewDoctor.statusCode != 200) {
          print('Medical folder registration failed with the new doctor: ${responseMedicalFolderWithNewDoctor.statusCode} - ${responseMedicalFolderWithNewDoctor.body}');
          showErrorSnackBar('Medical folder registration failed with the new doctor. Please try again.');
          return;
        }

        final dynamic decodedResponse = json.decode(responseMedicalFolderWithNewDoctor.body);
        idFolder = decodedResponse['id_folder'] as int?;
      } else {
        final responseMedicalFolder = await http.post(
          Uri.parse('${ApiUrls.medicalFolderUrlPrefix}${widget.patientId}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'diabetes_type': diabeteController.text.isNotEmpty ? diabeteController.text : null,
            'diabetes_history': diabHisController.text.isNotEmpty ? diabHisController.text : null,
            'weight': weightController.text.isNotEmpty ? weightController.text : null,
            'height': heightController.text.isNotEmpty ? heightController.text : null,
            'id_doctor': selectedDoctorId,
          }),
        );

        if (responseMedicalFolder.statusCode != 200) {
          print('Medical folder registration failed: ${responseMedicalFolder.statusCode} - ${responseMedicalFolder.body}');
          showErrorSnackBar('Medical folder registration failed. Please try again.');
          return;
        }

        final dynamic decodedResponse = json.decode(responseMedicalFolder.body);
        idFolder = decodedResponse['id_folder'] as int?;
      }

      if (idFolder == null) {
        print('Error: id_folder is null or not found in response.');
        showErrorSnackBar('Error: id_folder is null or not found in response.');
        return;
      }

      // Register DKA history
      for (final dkaHistoryData in savedDkaHistoryList) {
        final responseDkaHistory = await http.post(
          Uri.parse(ApiUrls.createDkaHistoryUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'order': dkaHistoryData['order'],
            'acetoneqt': dkaHistoryData['acetoneqt'],
            'date': dkaHistoryData['date'],
            'id_folder': idFolder,
          }),
        );

        if (responseDkaHistory.statusCode != 201) {
          print('DKA History registration failed: ${responseDkaHistory.statusCode} - ${responseDkaHistory.body}');
          showErrorSnackBar('DKA History registration failed. Please try again.');
          return;
        }
      }

      showSuccessDialog();

      if (selectedDoctorId != null) {
        final responseUpdateDoctor = await http.put(
          Uri.parse('${ApiUrls.patientsDoctorUrlPrefix}${widget.patientId}/doctor/$selectedDoctorId'),
        );
        if (responseUpdateDoctor.statusCode != 200) {
          showErrorSnackBar('Failed to update patient with doctor. Please try again.');
        } else {
          print('Patient updated with doctor successfully!');
        }
      }
    } catch (error) {
      print('Error during medical folder registration: $error');
      _showErrorSnackBar('Failed to register medical folder. Please try again.');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text(
            "Your medical folder is registered.\nNow you are ready to begin your journey with us!!.",
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
          ],
        );
      },
    );
  }
  void saveDkaHistory() {
    setState(() {
      savedDkaHistoryList.add({
        'order': dkaOrderValue,
        'acetoneqt': double.parse(acetoneController.text),
        'date': dateController.text,
      });
      dkaOrderValue = null;
      acetoneController.clear();
      dateController.clear();
    });
  }
  void _showErrorSnackBar(String message) {
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
    fetchDoctors(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Medical Folder Registration',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFB0EFE9),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.sick, color: Color(0xFF199A8E)),
                      labelText: 'Diabetes Type',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF199A8E)),
                      ),
                    ),
                    value: diabeteController.text.isNotEmpty
                        ? diabeteController.text
                        : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        diabeteController.text = newValue!;
                      });
                    },
                    items: ['Type 1', 'Type 2'].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: diabHisController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.history, color: Color(0xFF199A8E)),
                      labelText: 'Diabetes Diagnosis Date',
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
                          _selectDate(context, diabHisController);
                        },
                        child: Icon(Icons.calendar_today, color: Color(0xFF199A8E)),
                      ),
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, diabHisController);
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Turn on to enter your DKA history'),
                      Switch(
                        value: showDKHFields,
                        onChanged: (value) {
                          setState(() {
                            showDKHFields = value;
                          });
                        },
                        activeColor: Colors.tealAccent[700],
                      ),
                    ],
                  ),
                  Visibility(
                    visible: showDKHFields,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'DKA Order',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            prefixIcon: Icon(
                              Icons.history,
                              color: Color(0xFF199A8E),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                          value: dkaOrderValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              dkaOrderValue = newValue!;
                            });
                          },
                          items: [
                            'First Time',
                            'Second Time',
                            'Third Time',
                            'Fourth Time',
                            'Fifth Time',
                            'Sixth Time',
                            'Seventh Time',
                            'Eighth Time',
                            'Ninth Time',
                            'Tenth Time',
                            'More than Ten Times',
                          ].map((String order) {
                            return DropdownMenuItem<String>(
                              value: order,
                              child: Text(order),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: acetoneController,
                          decoration: InputDecoration(
                            labelText: 'Ketone Level In ppm',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                            prefixIcon: Icon(
                              Icons.history,
                              color: Color(0xFF199A8E),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF199A8E),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(
                            prefixIcon:
                            Icon(Icons.person_outline, color: Color(0xFF199A8E)),
                            labelText: 'Date',
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
                                _selectDate(context,dateController);
                              },
                              child: Icon(Icons.calendar_today, color: Color(0xFF199A8E)),
                            ),
                          ),
                          readOnly: true,
                          onTap: () {
                            _selectDate(context,dateController);
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: saveDkaHistory,
                          child: Text('Save DKA History',style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF199A8E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Turn off if your doctor not listed'),
                      Switch(
                        value: selectDoctorFromList,
                        onChanged: (value) {
                          setState(() {
                            selectDoctorFromList = value;
                          });
                        },
                        activeColor: Colors.tealAccent[700],
                      ),
                    ],
                  ),
                  Visibility(
                    visible: selectDoctorFromList,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Doctor',
                        labelStyle: TextStyle(
                            color: Colors.black, fontSize: 18),
                        prefixIcon: Icon(Icons.person,
                            color: Color(0xFF199A8E)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF199A8E), width: 2.0),
                        ),
                      ),
                      value: doctorFirstNameController.text.isNotEmpty
                          ? int.tryParse(doctorFirstNameController.text)
                          : null,
                      onChanged: (int? newValue) {
                        setState(() {
                          final selectedDoctor = doctorsList.firstWhere(
                                (doctor) =>
                            doctor['id_doctor'] == newValue,
                            orElse: () => {'first_name': '', 'last_name': ''},
                          );
                          doctorFirstNameController.text =
                              selectedDoctor['id_doctor'].toString();
                        });
                      },
                      items: doctorsList.map((doctor) {
                        return DropdownMenuItem<int>(
                          value: doctor['id_doctor'],
                          child: Container(
                            child: Text(
                              '${doctor['first_name']} ${doctor['last_name']}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                      style: TextStyle(color: Colors.black),
                      icon: Icon(Icons.arrow_drop_down,
                          color: Color(0xFF199A8E)),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (!selectDoctorFromList)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Enter Your Doctor Details'),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: doctorFirstNameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,
                                color: Color(0xFF199A8E)),
                            labelText: 'Doctor First Name',
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
                        SizedBox(height: 10),
                        TextFormField(
                          controller: doctorLastNameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,
                                color: Color(0xFF199A8E)),
                            labelText: 'Doctor Last Name',
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
                    ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.scale,
                          color: Color(0xFF199A8E)),
                      labelText: 'Weight In kg',
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
                  SizedBox(height: 10),
                  TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.horizontal_rule,
                          color: Color(0xFF199A8E)),
                      labelText: 'Height In cm',
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
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.2,
                        vertical: MediaQuery.of(context).size.height * 0.04),
                    child: ElevatedButton(
                      onPressed: () {
                        registerMedicalFolder(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                            MediaQuery.of(context).size.height * 0.02),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize:
                            MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical:
                            MediaQuery.of(context).size.height * 0.001),
                        minimumSize: Size(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height * 0.05),
                        backgroundColor: Color(0xFF199A8E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}