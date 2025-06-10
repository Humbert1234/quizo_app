import 'package:flutter/material.dart';
import 'package:quizo_app/screens/quiz_screen.dart';
import 'package:quizo_app/screens/performance_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedTheme;

  final List<String> _quizThemes = const [
    "Art",
    "Design",
    "History",
    "Mathematics",
    "Literature",
    "Geography",
    "Code",
    "Science",
    "General Knowledge",
  ];

  Widget _buildThemeButton(String themeName) {
    final isSelected = _selectedTheme == themeName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = themeName;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple[400]
              : const Color.fromARGB(0, 27, 4, 4),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: isSelected ? Colors.deepPurple[400]! : Colors.grey,
            width: 2.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          themeName,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final crossAxisCount = isSmallScreen ? 2 : 3;
    final itemAspectRatio = isSmallScreen ? 2.5 : 3.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: isSmallScreen ? 40.0 : 60.0),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.leaderboard,
                    color: Colors.black,
                    size: 30.0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PerformanceScreen(userId: widget.userId),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: isSmallScreen ? 10.0 : 20.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'lib/images/speech_bubble.png',
                    height: isSmallScreen ? 120 : 150,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 30.0 : 50.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: itemAspectRatio,
                ),
                itemCount: _quizThemes.length,
                itemBuilder: (context, index) {
                  final theme = _quizThemes[index];
                  return _buildThemeButton(theme);
                },
              ),
              SizedBox(height: isSmallScreen ? 40.0 : 60.0),
              Container(
                width: double.infinity,
                height: isSmallScreen ? 50.0 : 60.0,
                margin: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 0.0 : 30.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: MaterialButton(
                  onPressed: _selectedTheme == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(
                                userId: widget.userId,
                                quizTheme: _selectedTheme!,
                              ),
                            ),
                          );
                        },
                  child: const Text(
                    'Let\'s Start!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20.0 : 30.0), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
