import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(UserManualApp());
}

class UserManualApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserManualPage(),
    );
  }
}

class UserManualPage extends StatelessWidget {
  final String _pdfUrl = 'http://192.168.247.226:3000/user_manual.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final pdfPath = await downloadPDF(_pdfUrl);
            if (pdfPath != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewPage(pdfPath: pdfPath),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to download PDF'),
                ),
              );
            }
          },
          child: Text('Open PDF'),
        ),
      ),
    );
  }

  Future<String?> downloadPDF(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/user_manual.pdf';
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }
}

class PdfViewPage extends StatelessWidget {
  final String pdfPath;

  const PdfViewPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF View'),
      ),
      body: Center(
        child: PDFView(filePath: pdfPath),
      ),
    );
  }
}
