import 'package:flutter/material.dart';
import 'package:quizo_app/screens/results_screen.dart';

class QuizScreen extends StatefulWidget {
  final int userId;
  final String quizTheme;

  const QuizScreen({super.key, required this.userId, required this.quizTheme});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answerSelected = false;
  String? _selectedAnswer;
  Color? _feedbackColor;

  List<Map<String, dynamic>> get _questions {
    switch (widget.quizTheme) {
      case 'History':
        return _historyQuestions;
      case 'Science':
        return _scienceQuestions;
      case 'General Knowledge':
        return _generalKnowledgeQuestions;
      case 'Mathematics':
        return _mathematicsQuestions;
      case 'Literature':
        return _literatureQuestions;
      default:
        return _generalKnowledgeQuestions;
    }
  }

  final List<Map<String, dynamic>> _historyQuestions = [
    {
      'question': 'Who was the first President of the United States?',
      'options': [
        'Thomas Jefferson',
        'George Washington',
        'John Adams',
        'Benjamin Franklin',
      ],
      'answer': 'George Washington',
    },
    {
      'question': 'In which year did World War II end?',
      'options': ['1943', '1944', '1945', '1946'],
      'answer': '1945',
    },
    {
      'question': 'Who was the first Emperor of Rome?',
      'options': ['Julius Caesar', 'Augustus', 'Nero', 'Constantine'],
      'answer': 'Augustus',
    },
    {
      'question': 'Which ancient civilization built the Machu Picchu?',
      'options': ['Aztecs', 'Mayans', 'Incas', 'Olmecs'],
      'answer': 'Incas',
    },
    {
      'question': 'Who was the first woman to win a Nobel Prize?',
      'options': [
        'Marie Curie',
        'Mother Teresa',
        'Jane Addams',
        'Pearl S. Buck',
      ],
      'answer': 'Marie Curie',
    },
    {
      'question': 'Which empire was ruled by Genghis Khan?',
      'options': [
        'Ottoman Empire',
        'Mongol Empire',
        'Roman Empire',
        'Byzantine Empire',
      ],
      'answer': 'Mongol Empire',
    },
    {
      'question': 'In which year did the Titanic sink?',
      'options': ['1910', '1912', '1914', '1916'],
      'answer': '1912',
    },
    {
      'question':
          'Who was the first female Prime Minister of the United Kingdom?',
      'options': [
        'Margaret Thatcher',
        'Theresa May',
        'Indira Gandhi',
        'Golda Meir',
      ],
      'answer': 'Margaret Thatcher',
    },
    {
      'question': 'Which ancient wonder was located in Alexandria?',
      'options': [
        'Colossus of Rhodes',
        'Lighthouse of Alexandria',
        'Hanging Gardens',
        'Temple of Artemis',
      ],
      'answer': 'Lighthouse of Alexandria',
    },
    {
      'question': 'Who was the last Tsar of Russia?',
      'options': [
        'Nicholas II',
        'Peter the Great',
        'Catherine the Great',
        'Alexander III',
      ],
      'answer': 'Nicholas II',
    },
  ];

  final List<Map<String, dynamic>> _scienceQuestions = [
    {
      'question': 'What is the chemical symbol for gold?',
      'options': ['Ag', 'Fe', 'Au', 'Cu'],
      'answer': 'Au',
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'answer': 'Mars',
    },
    {
      'question': 'What is the hardest natural substance on Earth?',
      'options': ['Gold', 'Iron', 'Diamond', 'Platinum'],
      'answer': 'Diamond',
    },
    {
      'question': 'What is the main component of the Sun?',
      'options': ['Helium', 'Hydrogen', 'Oxygen', 'Carbon'],
      'answer': 'Hydrogen',
    },
    {
      'question': 'What is the study of fossils called?',
      'options': ['Paleontology', 'Archaeology', 'Geology', 'Anthropology'],
      'answer': 'Paleontology',
    },
    {
      'question': 'What is the largest organ in the human body?',
      'options': ['Heart', 'Brain', 'Liver', 'Skin'],
      'answer': 'Skin',
    },
    {
      'question': 'What is the process by which plants make their food?',
      'options': ['Respiration', 'Photosynthesis', 'Digestion', 'Fermentation'],
      'answer': 'Photosynthesis',
    },
    {
      'question': 'What is the atomic number of carbon?',
      'options': ['6', '12', '14', '16'],
      'answer': '6',
    },
    {
      'question': 'What is the speed of light in vacuum?',
      'options': [
        '299,792,458 m/s',
        '299,792,458 km/s',
        '299,792,458 m/h',
        '299,792,458 km/h',
      ],
      'answer': '299,792,458 m/s',
    },
    {
      'question': 'What is the study of earthquakes called?',
      'options': ['Meteorology', 'Seismology', 'Volcanology', 'Geology'],
      'answer': 'Seismology',
    },
  ];

  final List<Map<String, dynamic>> _generalKnowledgeQuestions = [
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'answer': 'Paris',
    },
    {
      'question': 'Which is the largest ocean on Earth?',
      'options': [
        'Atlantic Ocean',
        'Indian Ocean',
        'Arctic Ocean',
        'Pacific Ocean',
      ],
      'answer': 'Pacific Ocean',
    },
    {
      'question': 'What is the currency of Japan?',
      'options': ['Won', 'Yen', 'Ringgit', 'Baht'],
      'answer': 'Yen',
    },
    {
      'question': 'Which country has the most natural lakes?',
      'options': ['Canada', 'Russia', 'United States', 'Finland'],
      'answer': 'Canada',
    },
    {
      'question': 'What is the largest desert in the world?',
      'options': [
        'Gobi Desert',
        'Sahara Desert',
        'Antarctic Desert',
        'Arabian Desert',
      ],
      'answer': 'Antarctic Desert',
    },
    {
      'question': 'Which is the most spoken language in the world?',
      'options': ['English', 'Spanish', 'Mandarin Chinese', 'Hindi'],
      'answer': 'Mandarin Chinese',
    },
    {
      'question': 'What is the tallest mountain in the world?',
      'options': ['K2', 'Mount Everest', 'Kangchenjunga', 'Lhotse'],
      'answer': 'Mount Everest',
    },
    {
      'question': 'Which country has the most time zones?',
      'options': ['United States', 'Russia', 'France', 'United Kingdom'],
      'answer': 'France',
    },
    {
      'question': 'What is the largest mammal in the world?',
      'options': ['African Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus'],
      'answer': 'Blue Whale',
    },
    {
      'question': 'Which is the most populous city in the world?',
      'options': ['Tokyo', 'Delhi', 'Shanghai', 'São Paulo'],
      'answer': 'Tokyo',
    },
  ];

  final List<Map<String, dynamic>> _mathematicsQuestions = [
    {
      'question': 'What is the value of π (pi) to two decimal places?',
      'options': ['3.14', '3.16', '3.12', '3.18'],
      'answer': '3.14',
    },
    {
      'question': 'What is the square root of 144?',
      'options': ['12', '14', '16', '18'],
      'answer': '12',
    },
    {
      'question': 'What is the sum of angles in a triangle?',
      'options': ['90 degrees', '180 degrees', '270 degrees', '360 degrees'],
      'answer': '180 degrees',
    },
    {
      'question': 'What is the formula for the area of a circle?',
      'options': ['2πr', 'πr²', '2πr²', 'πr'],
      'answer': 'πr²',
    },
    {
      'question': 'What is the next number in the sequence: 2, 4, 8, 16, ...?',
      'options': ['24', '32', '30', '28'],
      'answer': '32',
    },
    {
      'question': 'What is the derivative of x²?',
      'options': ['x', '2x', '2', 'x²'],
      'answer': '2x',
    },
    {
      'question': 'What is the value of 5! (5 factorial)?',
      'options': ['100', '120', '60', '20'],
      'answer': '120',
    },
    {
      'question': 'What is the formula for the volume of a sphere?',
      'options': ['4πr²', '4πr³', '4/3πr³', '4/3πr²'],
      'answer': '4/3πr³',
    },
    {
      'question': 'What is the sum of the first 10 natural numbers?',
      'options': ['45', '50', '55', '60'],
      'answer': '55',
    },
    {
      'question': 'What is the value of sin(90°)?',
      'options': ['0', '0.5', '1', 'undefined'],
      'answer': '1',
    },
  ];

  final List<Map<String, dynamic>> _literatureQuestions = [
    {
      'question': 'Who wrote "Romeo and Juliet"?',
      'options': [
        'Charles Dickens',
        'William Shakespeare',
        'Jane Austen',
        'Mark Twain',
      ],
      'answer': 'William Shakespeare',
    },
    {
      'question': 'What is the first book in the Harry Potter series?',
      'options': [
        'The Chamber of Secrets',
        'The Philosopher\'s Stone',
        'The Prisoner of Azkaban',
        'The Goblet of Fire',
      ],
      'answer': 'The Philosopher\'s Stone',
    },
    {
      'question': 'Who wrote "Pride and Prejudice"?',
      'options': [
        'Emily Brontë',
        'Jane Austen',
        'Charlotte Brontë',
        'Virginia Woolf',
      ],
      'answer': 'Jane Austen',
    },
    {
      'question': 'What is the name of the author of "1984"?',
      'options': [
        'Aldous Huxley',
        'George Orwell',
        'Ray Bradbury',
        'H.G. Wells',
      ],
      'answer': 'George Orwell',
    },
    {
      'question': 'Who wrote "The Great Gatsby"?',
      'options': [
        'Ernest Hemingway',
        'F. Scott Fitzgerald',
        'John Steinbeck',
        'William Faulkner',
      ],
      'answer': 'F. Scott Fitzgerald',
    },
    {
      'question': 'What is the first book in "The Lord of the Rings" trilogy?',
      'options': [
        'The Two Towers',
        'The Fellowship of the Ring',
        'The Return of the King',
        'The Hobbit',
      ],
      'answer': 'The Fellowship of the Ring',
    },
    {
      'question': 'Who wrote "To Kill a Mockingbird"?',
      'options': [
        'Harper Lee',
        'J.D. Salinger',
        'John Steinbeck',
        'Ernest Hemingway',
      ],
      'answer': 'Harper Lee',
    },
    {
      'question': 'What is the name of the author of "The Catcher in the Rye"?',
      'options': [
        'J.D. Salinger',
        'F. Scott Fitzgerald',
        'Ernest Hemingway',
        'John Steinbeck',
      ],
      'answer': 'J.D. Salinger',
    },
    {
      'question': 'Who wrote "The Odyssey"?',
      'options': ['Homer', 'Virgil', 'Sophocles', 'Aristotle'],
      'answer': 'Homer',
    },
    {
      'question': 'What is the name of the author of "The Divine Comedy"?',
      'options': [
        'Dante Alighieri',
        'Giovanni Boccaccio',
        'Petrarch',
        'Machiavelli',
      ],
      'answer': 'Dante Alighieri',
    },
  ];

  void _checkAnswer(String selectedOption) {
    if (_answerSelected) return; // Prevent multiple selections

    setState(() {
      _answerSelected = true;
      _selectedAnswer = selectedOption;
      if (selectedOption == _questions[_currentQuestionIndex]['answer']) {
        _score++;
        _feedbackColor = Colors.green;
      } else {
        _feedbackColor = Colors.red;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _answerSelected = false;
        _selectedAnswer = null;
        _feedbackColor = null;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              userId: widget.userId,
              quizTheme: widget.quizTheme,
              score: _score,
              totalQuestions: _questions.length,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz on ${widget.quizTheme}'),
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 22.0),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion['options'].length,
                itemBuilder: (context, index) {
                  String option = currentQuestion['options'][index];
                  bool isCorrect = option == currentQuestion['answer'];
                  bool isSelected = option == _selectedAnswer;

                  Color? buttonColor;
                  if (_answerSelected) {
                    if (isSelected) {
                      buttonColor = _feedbackColor;
                    } else if (isCorrect) {
                      buttonColor = Colors.green;
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: buttonColor,
                    child: ListTile(
                      title: Text(option),
                      onTap: _answerSelected
                          ? null
                          : () => _checkAnswer(option),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
