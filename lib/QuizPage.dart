import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_urls.dart';
import 'package:confetti/confetti.dart';

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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
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
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _questions = data.map((item) => QuizQuestion.fromJson(item)).toList();
          _questions.shuffle(); // Shuffle the list of questions
        });
      } else {
        throw Exception('Failed to load quiz data');
      }
    } catch (error) {
      print('Error fetching quiz data: $error');
    }
  }

  void _checkAnswer(int selectedOptionIndex) {
    if (_answeredCorrectly) return;

    final correctOptionIndex = _questions[_currentQuestionIndex].correctOptionIndex;
    setState(() {
      _selectedOptionIndex = selectedOptionIndex;
      _answeredCorrectly = selectedOptionIndex == correctOptionIndex;
      if (_answeredCorrectly) {
        _score += 10;
        _confettiController.play();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _answeredCorrectly = false;
      _selectedOptionIndex = null;
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    ElevatedButton? nextQuestionButton;
    if (_selectedOptionIndex != null) {
      nextQuestionButton = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          minimumSize: Size(screenWidth * 0.3, screenHeight * 0.1),
        ),
        onPressed: _nextQuestion,
        child: Text(
          'Next Question',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[50],
        elevation: 0,
        title: Text(
          'Quiz',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Score : $_score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/quiiz.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                MediaQuery.of(context).padding.top + kToolbarHeight - 65,
                19,
                17,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      _questions[_currentQuestionIndex].question,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.0, fontFamily: 'Poppins'),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  ..._questions[_currentQuestionIndex]
                      .options
                      .asMap()
                      .entries
                      .map(
                        (entry) {
                      final isSelected = _selectedOptionIndex == entry.key;
                      final isCorrect = entry.key == _questions[_currentQuestionIndex].correctOptionIndex;
                      final color = isSelected
                          ? _answeredCorrectly
                          ? Colors.green
                          : Colors.red
                          : null;

                      return Column(
                        children: [
                          SizedBox(height: screenHeight * 0.0125),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
                                  blurRadius: 5,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _checkAnswer(entry.key);
                              },
                              style: ButtonStyle(
                                backgroundColor: _selectedOptionIndex != null && entry.key == _questions[_currentQuestionIndex].correctOptionIndex
                                    ? MaterialStateProperty.all<Color>(Colors.green)
                                    : _selectedOptionIndex == entry.key && !_answeredCorrectly
                                    ? MaterialStateProperty.all<Color>(Colors.red)
                                    : MaterialStateProperty.all<Color>(Colors.green[50]!),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                elevation: MaterialStateProperty.all<double>(0),
                                minimumSize: MaterialStateProperty.all<Size>(Size(screenWidth * 0.65, screenHeight * 0.075)),
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
                          ),
                          SizedBox(height: screenHeight * 0.0125),
                        ],
                      );
                    },
                  ).toList(),
                  if (_answeredCorrectly)
                    Positioned.fill(
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
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(screenWidth * 0.3, screenHeight * 0.1),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Exit Quiz',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (nextQuestionButton != null) nextQuestionButton,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
