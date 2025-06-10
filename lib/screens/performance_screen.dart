// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:quizo_app/database_helper.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:fl_chart/fl_chart.dart';
import 'dart:math'; // Import for max function

class PerformanceScreen extends StatefulWidget {
  final int userId;

  const PerformanceScreen({super.key, required this.userId});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _performanceHistory = [];
  bool _isLoading = true;

  int _lifetimePoints = 0;
  int _quizzesPassed = 0;
  int _perfectScores = 0;

  Map<String, dynamic>? _overallStats;

  List<FlSpot> _recentPerformanceSpots = [];
  List<DateTime> _recentPerformanceDates = [];

  @override
  void initState() {
    super.initState();
    _loadPerformanceHistory();
  }

  void _loadPerformanceHistory() async {
    final overallStats = await _databaseHelper.getOverallQuizStatistics(
      widget.userId,
    );
    final recentHistory = await _databaseHelper.getPerformanceByUser(
      widget.userId,
      limit: 10,
    );

    setState(() {
      _overallStats = overallStats;
      _lifetimePoints = overallStats['lifetime_points'] ?? 0;
      _quizzesPassed = overallStats['quizzes_passed'] ?? 0;
      _perfectScores = overallStats['perfect_scores'] ?? 0;

      _performanceHistory =
          recentHistory; // Only keep recent history for the list
      _isLoading = false;

      // Prepare data for the chart (last 10 quizzes from recentHistory)
      _recentPerformanceSpots = [];
      _recentPerformanceDates = [];
      for (int i = 0; i < _performanceHistory.length; i++) {
        final entry = _performanceHistory[i];
        _recentPerformanceSpots.add(
          FlSpot(i.toDouble(), (entry['score'] as int).toDouble()),
        );
        _recentPerformanceDates.add(DateTime.parse(entry['date']));
      }
    });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                        interval: _lifetimePoints > 0
                                            ? (_lifetimePoints / 5)
                                                  .ceilToDouble()
                                            : 200,
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
                                                DateFormat(
                                                  'MMM dd',
                                                ).format(date),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
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
                                  maxX:
                                      (_recentPerformanceSpots.length > 0
                                              ? _recentPerformanceSpots.length -
                                                    1
                                              : 0)
                                          .toDouble(),
                                  minY: 0,
                                  maxY: _recentPerformanceSpots.isNotEmpty
                                      ? _recentPerformanceSpots
                                                .map((e) => e.y.toInt())
                                                .reduce(max)
                                                .toDouble() *
                                            1.2
                                      : 1000,
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
                                        color: Colors.deepPurpleAccent
                                            .withOpacity(0.3),
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
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
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
                          '${_overallStats?['total_quizzes'] ?? 0}',
                          'Quizzes Taken',
                          Colors.deepPurpleAccent,
                        ),
                        _buildAchievementCard(
                          Icons.monetization_on,
                          '${_lifetimePoints}',
                          'Lifetime Point',
                          Colors.orangeAccent,
                        ),
                        _buildAchievementCard(
                          Icons.local_fire_department,
                          '${_quizzesPassed}',
                          'Quiz Passed',
                          Colors.redAccent,
                        ),
                        _buildAchievementCard(
                          Icons.emoji_events,
                          '${_perfectScores}',
                          'Perfect Scores',
                          Colors.amber,
                        ),
                        // Removed Icons.ads_click as it's not directly represented in achievements
                        // _buildAchievementCard(Icons.ads_click, '269', 'Challenge Passed', Colors.greenAccent),
                        // Removed Fastest Record as quiz duration is not tracked
                        // _buildAchievementCard(Icons.access_time, '72', 'Fastest Record', Colors.lightBlueAccent),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    if (_performanceHistory.isNotEmpty)
                      const Text(
                        'Recent Quiz Performance',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_performanceHistory.isNotEmpty)
                      const SizedBox(height: 20.0),
                    if (_performanceHistory.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _performanceHistory.reversed.take(10).length,
                        itemBuilder: (context, index) {
                          final entry = _performanceHistory.reversed
                              .take(10)
                              .toList()[index];
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
