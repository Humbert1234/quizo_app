// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PerformanceScreen extends StatefulWidget {
  final int userId;

  const PerformanceScreen({super.key, required this.userId});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  // Static data
  final int _lifetimePoints = 1250;
  final int _quizzesPassed = 15;
  final int _perfectScores = 3;
  final int _totalQuizzes = 20;

  // Static performance data for the last 10 quizzes
  final List<Map<String, dynamic>> _performanceHistory = [
    {'date': '2024-03-20', 'quiz_theme': 'History', 'score': 850},
    {'date': '2024-03-19', 'quiz_theme': 'Science', 'score': 920},
    {'date': '2024-03-18', 'quiz_theme': 'Mathematics', 'score': 780},
    {'date': '2024-03-17', 'quiz_theme': 'Literature', 'score': 950},
    {'date': '2024-03-16', 'quiz_theme': 'General Knowledge', 'score': 880},
    {'date': '2024-03-15', 'quiz_theme': 'History', 'score': 900},
    {'date': '2024-03-14', 'quiz_theme': 'Science', 'score': 850},
    {'date': '2024-03-13', 'quiz_theme': 'Mathematics', 'score': 920},
    {'date': '2024-03-12', 'quiz_theme': 'Literature', 'score': 890},
    {'date': '2024-03-11', 'quiz_theme': 'General Knowledge', 'score': 950},
  ];

  List<FlSpot> _recentPerformanceSpots = [];
  List<DateTime> _recentPerformanceDates = [];

  @override
  void initState() {
    super.initState();
    _prepareChartData();
  }

  void _prepareChartData() {
    _recentPerformanceSpots = [];
    _recentPerformanceDates = [];
    for (int i = 0; i < _performanceHistory.length; i++) {
      final entry = _performanceHistory[i];
      _recentPerformanceSpots.add(
        FlSpot(i.toDouble(), (entry['score'] as int).toDouble()),
      );
      _recentPerformanceDates.add(DateTime.parse(entry['date']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('My Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Point this Week',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_lifetimePoints} Pt',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                  interval: 200,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() <
                                        _recentPerformanceDates.length) {
                                      final DateTime date =
                                          _recentPerformanceDates[value
                                              .toInt()];
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          DateFormat('MMM dd').format(date),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 30,
                                  interval: 1,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: const Color(0xff37434d),
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: (_recentPerformanceSpots.length - 1)
                                .toDouble(),
                            minY: 0,
                            maxY: 1000,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _recentPerformanceSpots,
                                isCurved: true,
                                color: Colors.deepPurpleAccent,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.deepPurpleAccent.withOpacity(
                                    0.3,
                                  ),
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
              const SizedBox(height: 30.0),
              const Text(
                'Your Achievements',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildAchievementCard(
                    Icons.question_answer,
                    '$_totalQuizzes',
                    'Quizzes Taken',
                    Colors.deepPurpleAccent,
                  ),
                  _buildAchievementCard(
                    Icons.monetization_on,
                    '$_lifetimePoints',
                    'Lifetime Point',
                    Colors.orangeAccent,
                  ),
                  _buildAchievementCard(
                    Icons.local_fire_department,
                    '$_quizzesPassed',
                    'Quiz Passed',
                    Colors.redAccent,
                  ),
                  _buildAchievementCard(
                    Icons.emoji_events,
                    '$_perfectScores',
                    'Perfect Scores',
                    Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Recent Quiz Performance',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _performanceHistory.length,
                itemBuilder: (context, index) {
                  final entry = _performanceHistory[index];
                  final DateTime date = DateTime.parse(entry['date']);
                  final String formattedDate = DateFormat(
                    'MMM dd, yyyy - hh:mm a',
                  ).format(date);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      title: Text('Theme: ${entry['quiz_theme']}'),
                      subtitle: Text(
                        'Score: ${entry['score']}\nDate: $formattedDate',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: color),
            const SizedBox(height: 10.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
