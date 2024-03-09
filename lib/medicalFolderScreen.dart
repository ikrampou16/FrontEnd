import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'regScreen.dart';

class MedicalFolderScreen extends StatefulWidget {
  @override
  _MedicalFolderScreenState createState() => _MedicalFolderScreenState();
}

class _MedicalFolderScreenState extends State<MedicalFolderScreen> {
  final TextEditingController diabetesTypeController = TextEditingController();
  final TextEditingController diabetesHistoryController = TextEditingController();
  final TextEditingController dkaHistoryController = TextEditingController();

  // Add a variable to store the patient ID
  // You should obtain and set this ID when the personal information is registered
  String? patientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Folder Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: diabetesTypeController,
              decoration: InputDecoration(labelText: 'Diabetes Type'),
            ),
            TextField(
              controller: diabetesHistoryController,
              decoration: InputDecoration(labelText: 'Diabetes History'),
            ),
            TextField(
              controller: dkaHistoryController,
              decoration: InputDecoration(labelText: 'DKA History'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validate and submit medical folder information
                submitMedicalFolderInformation(context);
              },
              child: Text(
                'Submit Medical Folder Information',
                style: TextStyle(
                  color: Color(0xFF199A8E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to submit both personal and medical information
  Future<void> submitMedicalFolderInformation(BuildContext context) async {
    // Check if the patient ID is available
    if (patientId == null) {
      // Handle the case where the patient ID is not available
      print('Patient ID is not available. Please register personal information first.');
      // You might want to show an error message to the user or handle it accordingly
      return;
    }

    // Validate and submit medical folder information
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:3000/api/medical-folder'), // Adjust the URL as needed
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'diabetes_type': diabetesTypeController.text,
          'diabetes_history': diabetesHistoryController.text,
          'dka_history': dkaHistoryController.text,
          'id_patient': patientId, // Use the patient ID obtained from the first registration
        }),
      );

      if (response.statusCode == 200) {
        // Medical folder information submitted successfully
        print('Medical folder information submitted successfully: ${response.body}');

        // Display a success dialog or navigate to the next screen
        // ...
      } else {
        // Medical folder information submission failed
        // Display an error message
        print('Medical folder information submission failed: ${response.statusCode} - ${response.body}');
        // Display an error message or handle accordingly
        // ...
      }
    } catch (error) {
      // Handle network or other errors
      print('Error during medical folder information submission: $error');
      // Display an error message or handle accordingly
      // ...
    }
  }
}
