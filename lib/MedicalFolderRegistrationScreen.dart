import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'api_urls.dart';
import 'loginScreen.dart';
import 'status_code.dart';

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
  String? smokeValue;
  String? selectedArea;
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
      final response = await http.get(Uri.parse(ApiUrls.doctorsNameUrl));

      if (response.statusCode == StatusCodes.ok) {
        final List<dynamic> decodedData = json.decode(response.body)['doctors'];
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

      // Check if a doctor is selected from the list or not
      if (selectDoctorFromList) {
        selectedDoctorId = int.tryParse(doctorFirstNameController.text);
      } else {
        doctorFirstName = doctorFirstNameController.text;
        doctorLastName = doctorLastNameController.text;
      }

      // Check if the patient ID is valid
      if (widget.patientId == null) {
        print('Error: Invalid patient ID');
        _showErrorSnackBar('Invalid patient ID. Please try again.');
        return;
      }

      // Create a new doctor if not selected from the list
      if (!selectDoctorFromList) {
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

        if (responseCreateDoctor.statusCode != StatusCodes.ok) {
          throw Exception('Doctor creation failed');
        }

        final Map<String, dynamic> createdDoctor = json.decode(responseCreateDoctor.body);
        selectedDoctorId = createdDoctor['id'];
      }

      // Prepare the request body for medical folder creation
      final Map<String, dynamic> requestBody = {
        'diabetes_type': diabeteController.text.isNotEmpty ? diabeteController.text : null,
        'diabetes_history': diabHisController.text.isNotEmpty ? diabHisController.text : null,
        'weight': weightController.text.isNotEmpty ? weightController.text : null,
        'height': heightController.text.isNotEmpty ? heightController.text : null,
        'id_doctor': selectedDoctorId,
      };

      // Include 'area' and 'is_smoke' only if not empty
      if (selectedArea != null && selectedArea!.isNotEmpty) {
        requestBody['area'] = selectedArea;
      }

      if (smokeValue != null && smokeValue!.isNotEmpty) {
        requestBody['is_smoke'] = smokeValue;
      }

      // Send the request to create a medical folder
      final responseMedicalFolder = await http.post(
        Uri.parse('${ApiUrls.medicalFolderUrlPrefix}${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (responseMedicalFolder.statusCode != StatusCodes.ok) {
        throw Exception('Medical folder registration failed');
      }

      final dynamic decodedResponse = json.decode(responseMedicalFolder.body);
      final int? idFolder = decodedResponse['id_folder'] as int?;

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

        if (responseDkaHistory.statusCode != StatusCodes.created) {
          throw Exception('DKA History registration failed');
        }
      }

      showSuccessDialog();

      // Update patient with doctor if selected
      if (selectedDoctorId != null) {
        final responseUpdateDoctor = await http.put(
          Uri.parse('${ApiUrls.patientsDoctorUrlPrefix}${widget.patientId}/doctor/$selectedDoctorId'),
        );
        if (responseUpdateDoctor.statusCode != StatusCodes.ok) {
          print('Failed to update patient with doctor');
        } else {
          print('Patient updated with doctor successfully!');
        }
      }
    } catch (error) {
      print('Error during medical folder registration: $error');
      _showErrorSnackBar('Failed to register medical folder. Please try again.');
    }
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

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              registerMedicalFolder(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.001,
              ),
              minimumSize: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height * 0.05,
              ),
              backgroundColor: Color(0xFF199A8E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.1,
                ),
              ),
            ),
          ),
        ));
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
            'Medical Folder Registration'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Diabetes Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.sick_outlined, color: Color(0xFF199A8E)),
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
                      prefixIcon: Icon(Icons.history_outlined, color: Color(0xFF199A8E)),
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
                        child: Icon(Icons.calendar_month_outlined, color: Color(0xFF199A8E)),
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
                              Icons.history_outlined,
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
                              Icons.history_outlined,
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
                              child: Icon(Icons.calendar_month_outlined, color: Color(0xFF199A8E)),
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
                        prefixIcon: Icon(Icons.person_outline,
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
                      icon: Icon(Icons.arrow_drop_down_outlined,
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
                            prefixIcon: Icon(Icons.person_outline,
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
                            prefixIcon: Icon(Icons.person_outline,
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
                  Text(
                    'General Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.scale_outlined,
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
                      prefixIcon: Icon(Icons.horizontal_rule_outlined,
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
                  Text('To improve recommendations ',style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16),),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Area',
                      labelStyle: TextStyle(
                          color: Colors.black, fontSize: 18),
                      prefixIcon: Icon(Icons.area_chart_outlined,
                          color: Color(0xFF199A8E)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF199A8E), width: 2.0),
                      ),
                    ),
                    value: selectedArea,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedArea = newValue!;
                      });
                    },
                    items: ['Northeast','Northwest','Southeast','Southwest','Center'].map((String area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    icon: Icon(Icons.arrow_drop_down_outlined,
                        color: Color(0xFF199A8E)),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Do you smoke?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: smokeValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            smokeValue = newValue;
                          });
                        },
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        underline: Container(
                          height: 2,
                          color: Colors.tealAccent[700],
                        ),
                        items: <String>['Choose an option', 'Yes', 'No'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value == 'Choose an option' ? null : value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildRegisterButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
