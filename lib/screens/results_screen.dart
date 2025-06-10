import 'package:flutter/material.dart';
import 'package:quizo_app/database_helper.dart';
import 'package:quizo_app/screens/home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final int userId;
  final String quizTheme;
  final int score;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.userId,
    required this.quizTheme,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _savePerformance();
  }

  void _savePerformance() async {
    Map<String, dynamic> performance = {
      'user_id': widget.userId,
      'quiz_theme': widget.quizTheme,
      'score': widget.score,
      'total_questions': widget.totalQuestions,
      'date': DateTime.now().toIso8601String(),
    };
    await _databaseHelper.insertPerformance(performance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You scored ${widget.score} out of ${widget.totalQuestions}!',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(userId: widget.userId),
                    ),
                    (route) => false, // Remove all routes from the stack
                  );
                },
                child: const Text('Back to Themes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
