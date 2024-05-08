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

  Future<void> submitMedicalFolderInformation(BuildContext context) async {
    if (patientId == null) {
      print('Patient ID is not available. Please register personal information first.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.8:3000/api/medical-folder'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'diabetes_type': diabetesTypeController.text,
          'diabetes_history': diabetesHistoryController.text,
          'dka_history': dkaHistoryController.text,
          'id_patient': patientId,
        }),
      );

      if (response.statusCode == 200) {
        print('Medical folder information submitted successfully: ${response.body}');

      } else {
        print('Medical folder information submission failed: ${response
            .statusCode} - ${response.body}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error during medical folder information submission: $error');

    }
  }
}
