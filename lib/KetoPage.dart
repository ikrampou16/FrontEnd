import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
class KetoPage extends StatefulWidget {
  @override
  _KetoPageState createState() => _KetoPageState();
}

class _KetoPageState extends State<KetoPage> {
  int refDevice = 0;
  String state = '';
  String _pdfUrl = 'http://192.168.1.3:3000/user_manual.pdf';
  String? _pdfPath;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    fetchDeviceInfo();
  }

  Future<void> fetchDeviceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patientId');

      if (patientId == null) {
        return;
      }

      final response = await http.get(
        Uri.parse(ApiUrls.devicesUrl(patientId)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          refDevice = data['ref_device'];
          state = data['state'];

          // Print state and refDevice after setting their values
          print('State: $state');
          print('Ref Device: $refDevice');
        });
      } else {
        print('Failed to fetch device: ${response.statusCode}');
        print('State: $state');
        print('Ref Device: $refDevice');
      }
    } catch (error) {
      print('Error fetching device information: $error');
    }
  }

  Future<void> downloadPdf() async {
    setState(() {
      _downloading = true;
    });

    final url = _pdfUrl;
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var path = "/storage/emulated/0/Download/";
        final file = File('$path/user_manual.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _pdfPath = file.path;
          print('PDF Path: $_pdfPath');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully'),
          ),
        );
      } else {
        print('Failed to download PDF: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF'),
          ),
        );
      }
    } catch (error) {
      print('Error downloading PDF: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading PDF'),
        ),
      );
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keto Page'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFB0EFE9),
            ],
          ),
        ),
        child: Center(
          child: _buildKetoContent(context),
        ),
      ),
    );
  }

  Widget _buildKetoContent(BuildContext context) {
    if (_downloading) {
      return CircularProgressIndicator();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingVertical = screenHeight * 0.05;
    final paddingHorizontal = screenWidth * 0.15;
    final titleFontSize = screenWidth * 0.055;
    final contentFontSize = screenWidth * 0.05;
    final buttonHeight = screenHeight * 0.07;
    final buttonFontSize = screenWidth * 0.04;

    // Display the button regardless of whether the user has a device or not
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: paddingVertical),
          child: Text(
            'Your Device Info:',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFF199A8E),
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: Column(
            children: [
              // Display device information if available
              if (refDevice != 0 && state.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Ref Device: $refDevice',
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'State: $state',
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                  ],
                )
              else
                Text(
                  "You don't have a device yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: contentFontSize,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: paddingVertical),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: ElevatedButton.icon(
            onPressed: () async {
              await downloadPdf();
              if (_pdfPath != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewPage(pdfPath: _pdfPath!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to download PDF.'),
                  ),
                );
              }
            },
            icon: Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF199A8E)),
            label: Text(
              'Click to view user manual',
              style: TextStyle(
                fontSize: buttonFontSize - 2,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(screenWidth * 0.4, screenHeight * 0.06),
            ),
          ),
        ),
      ],
    );
  }
}

class PdfViewPage extends StatelessWidget {
  final String pdfPath;

  const PdfViewPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Received PDF Path: $pdfPath');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PDF View',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: PDFView(filePath: pdfPath),
    );
  }
}
