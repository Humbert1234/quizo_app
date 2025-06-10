import 'package:flutter/material.dart';
import 'package:quizo_app/screens/quiz_screen.dart';
import 'package:quizo_app/screens/performance_screen.dart';

class HomeScreen extends StatelessWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  final List<String> quizThemes = const [
    "History",
    "Science",
    "General Knowledge",
    "Mathematics",
    "Literature",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizo App - Themes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerformanceScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: quizThemes.length,
        itemBuilder: (context, index) {
          final theme = quizThemes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(theme),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizScreen(userId: userId, quizTheme: theme),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
