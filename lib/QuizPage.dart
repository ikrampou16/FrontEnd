import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_urls.dart';
import 'package:confetti/confetti.dart';
import 'status_code.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answeredCorrectly = false;
  int? _selectedOptionIndex;
  bool _answerSelected = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    fetchQuizData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchQuizData() async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.quizUrl));
      if (response.statusCode == StatusCodes.ok) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _questions = data.map((item) => QuizQuestion.fromJson(item)).toList();
          _questions.shuffle();
        });
      } else {
        throw Exception('Failed to load quiz data');
      }
    } catch (error) {
      print('Error fetching quiz data: $error');
    }
  }

  void _checkAnswer(int selectedOptionIndex) {
    if (_answeredCorrectly || _answerSelected) return;

    final correctOptionIndex = _questions[_currentQuestionIndex].correctOptionIndex;
    setState(() {
      _selectedOptionIndex = selectedOptionIndex;
      _answeredCorrectly = selectedOptionIndex == correctOptionIndex;
      if (_answeredCorrectly) {
        _score += 10;
        _confettiController.play();
      }
      _answerSelected = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _answeredCorrectly = false;
      _selectedOptionIndex = null;
      _answerSelected = false;
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[200], // Set the color of the AppBar
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Back',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Question ${_currentQuestionIndex + 1}/20', // Display question length in the AppBar
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set the text color of the question length
                letterSpacing: 1.5,
              ),
            ),

          ],
        ),
      ),
      body: _questions.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              Container(
                height: screenHeight * 0.08,
                width: screenHeight * 0.08,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepOrange[400],
                ),
                child: Center(
                  child: Text(
                    '$_score',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: Colors.transparent, // Set color to transparent to use gradient
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [Colors.white, Colors.lightBlue[100]!],
                      ),
                    ),
                    child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Column(
                      children: [
                        Text(
                          _questions[_currentQuestionIndex].question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: _questions[_currentQuestionIndex].options
                                .asMap()
                                .entries
                                .map((entry) {
                              final isSelected =
                                  _selectedOptionIndex == entry.key;
                              final isCorrect = entry.key ==
                                  _questions[_currentQuestionIndex]
                                      .correctOptionIndex;
                              final color = isSelected
                                  ? _answeredCorrectly
                                  ? Colors.green
                                  : Colors.red
                                  : Colors.white;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _checkAnswer(entry.key);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: _selectedOptionIndex != null && entry.key == _questions[_currentQuestionIndex].correctOptionIndex
                                        ? MaterialStateProperty.all<Color>(Colors.green)
                                        : _selectedOptionIndex == entry.key && !_answeredCorrectly
                                        ? MaterialStateProperty.all<Color>(Colors.red)
                                        : MaterialStateProperty.all<Color>(Colors.white!),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        side: BorderSide(color: Colors.black),
                                      ),
                                    ),
                                    elevation: MaterialStateProperty.all<double>(0),
                                    minimumSize: MaterialStateProperty.all<Size>(
                                      Size(screenWidth * 0.65, 48.0),
                                    ),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (_answeredCorrectly)
                          SizedBox(
                            height: 100.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: ConfettiWidget(
                                confettiController: _confettiController,
                                blastDirection: -pi / 2,
                                emissionFrequency: 0.05,
                                numberOfParticles: 20,
                                maxBlastForce: 20,
                                minBlastForce: 5,
                                gravity: 0.1,
                              ),
                            ),
                          ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                EdgeInsets.symmetric(vertical: 15),
                                minimumSize:
                                Size(screenWidth * 0.3, 48.0),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Exit Quiz',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (_answerSelected)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15),
                                  minimumSize:
                                  Size(screenWidth * 0.3, 48.0),
                                ),
                                onPressed: _nextQuestion,
                                child: Text(
                                  'Next Question',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
    );
  }
}