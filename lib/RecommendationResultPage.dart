import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_urls.dart';
import 'status_code.dart';

class RecommendationResultPage extends StatefulWidget {
  final String recommendation;
  final int age;
  final String gender;
  final String diabetesType;
  final String isSmoke;
  final String area;

  RecommendationResultPage({
    required this.recommendation,
    required this.age,
    required this.gender,
    required this.diabetesType,
    required this.isSmoke,
    required this.area,
  });

  @override
  _RecommendationResultPageState createState() => _RecommendationResultPageState();
}

class _RecommendationResultPageState extends State<RecommendationResultPage> {
  late List<Map<String, dynamic>> sections;

  @override
  void initState() {
    super.initState();
    sections = parseRecommendations(widget.recommendation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Recommendation',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.teal[50],
      ),
      backgroundColor: Colors.teal[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  '-Swipe right to see more-',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFF199A8E), width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  section['title'],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                if (section['recommendations'].isNotEmpty)
                                  for (var recommendation in section['recommendations'])
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recommendation['text'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          if (recommendation['rating'] != null && recommendation['rating'] > 0)
                                            RatingBar.builder(
                                              initialRating: recommendation['rating'],
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemSize: 24.0,
                                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                              itemBuilder: (context, index) {
                                                return Icon(
                                                  index < recommendation['rating']
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                );
                                              },
                                              onRatingUpdate: (rating) {},
                                              ignoreGestures: true, // Set this property to true
                                            ),
                                        ],
                                      ),
                                    ),
                                if (section['mostRecommended'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Top Local Recommendation: ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${section['mostRecommended']}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Poppins',
                                              color: Color(0xFF199A8E),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.09, left: 30.0),
        child: FloatingActionButton(
          onPressed: () => _showAddRecommendationDialog(context),
          backgroundColor: Color(0xFF199A8E),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<Map<String, dynamic>> parseRecommendations(String recommendation) {
    final lines = recommendation.split('\n');
    final sections = <Map<String, dynamic>>[];
    String? currentSection;
    List<Map<String, dynamic>> currentRecommendations = [];
    String? mostRecommended;

    final sectionMapping = {
      'Recommendations for Nutrition and Diet': 'Nutrition and Diet',
      'Recommendations for Routine Physical Activities': 'Routine Physical Activities',
      'Recommendations for Self-care': 'Self-care',
      'Recommendations for Psycho-social Care': 'Psycho-social Care',
    };

    for (var line in lines) {
      if (line.startsWith('*')) {
        if (currentSection != null) {
          sections.add({
            'title': currentSection,
            'recommendations': currentRecommendations,
            'mostRecommended': mostRecommended,
          });
        }
        currentSection = sectionMapping[line] ?? line;
        currentRecommendations = [];
        mostRecommended = null;
      } else if (line.startsWith('Most recommended in your area:')) {
        mostRecommended = line.replaceFirst('Most recommended in your area: ', '');
      } else if (line.isNotEmpty) {
        final parts = line.split('(Rating: ');
        final text = parts[0].trim();
        final rating = parts.length > 1 ? double.tryParse(parts[1].replaceFirst('/5)', '')) ?? 0.0 : 0.0;
        currentRecommendations.add({'text': text, 'rating': rating});
      }
    }
    if (currentSection != null) {
      sections.add({
        'title': currentSection,
        'recommendations': currentRecommendations,
        'mostRecommended': mostRecommended,
      });
    }
    return sections;
  }

  Future<void> _showAddRecommendationDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final TextEditingController _recommendationController = TextEditingController();
    final TextEditingController _ratingController = TextEditingController();
    String? _selectedCategory;
    bool showError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Your Recommendation',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    showError = false;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'Nutrition and Diet',
                    child: Text('Nutrition and Diet'),
                  ),
                  DropdownMenuItem(
                    value: 'Routine Physical Activities',
                    child: Text('Routine Physical Activities'),
                  ),
                  DropdownMenuItem(
                    value: 'Self-care',
                    child: Text('Self-care'),
                  ),
                  DropdownMenuItem(
                    value: 'Psycho-social Care',
                    child: Text('Psycho-social Care'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _recommendationController,
                decoration: InputDecoration(
                  labelText: 'Your Recommendation',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(
                  labelText: 'Rating (1-5)',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    showError = false;
                  });
                  if (value.isNotEmpty) {
                    double rating = double.tryParse(value) ?? 0.0;
                    if (rating < 1 || rating > 5) {
                      _ratingController.clear();
                    }
                  }
                },
              ),
              if (showError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'You need to fill all fields and select a category.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedCategory == null ||
                      _recommendationController.text.isEmpty ||
                      _ratingController.text.isEmpty) {
                    setState(() {
                      showError = true;
                    });
                    return;
                  }
                  await _sendRecommendation(
                    _selectedCategory!,
                    _recommendationController.text,
                    double.parse(_ratingController.text),
                  );
                  Navigator.of(context).pop();
                  _showThankYouDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF199A8E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Send'),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendRecommendation(String category, String recommendation, double rating) async {

    final responseadd = await http.post(
      Uri.parse(ApiUrls.addRecommendation),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'typerecommendation': category,
        'rating': rating,
        'recommendation': recommendation,
        'age': widget.age,
        'diabetesType': widget.diabetesType,
        'gender': widget.gender,
        'area': widget.area,
        'isSmoke': widget.isSmoke,
      }),
    );

    if (responseadd.statusCode == StatusCodes.ok) {
      print('Recommendation sent successfully');
    } else {
      print('Failed to send recommendation');
    }
  }

  void _showThankYouDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Color(0xFF199A8E),
              size: 64.0,
            ),
            SizedBox(height: 16.0),
            Text(
              "It's Done!",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Thank you for sharing your experience!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF199A8E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}
