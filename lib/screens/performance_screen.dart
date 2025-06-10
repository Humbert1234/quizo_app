// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps, prefer_is_empty, unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quizo_app/database_helper.dart';

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
  String? _error;

  // Data variables
  int _lifetimePoints = 0;
  int _quizzesPassed = 0;
  int _perfectScores = 0;
  int _totalQuizzes = 0;
  Map<String, dynamic>? _overallStats;
  List<FlSpot> _recentPerformanceSpots = [];
  List<DateTime> _recentPerformanceDates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load overall statistics
      final overallStats = await _databaseHelper.getOverallQuizStatistics(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        _overallStats = overallStats;
        _lifetimePoints = overallStats['lifetime_points'] ?? 0;
        _quizzesPassed = overallStats['quizzes_passed'] ?? 0;
        _perfectScores = overallStats['perfect_scores'] ?? 0;
        _totalQuizzes = overallStats['total_quizzes'] ?? 0;
      });

      // Load recent performance history
      final recentHistory = await _databaseHelper.getPerformanceByUser(
        widget.userId,
        limit: 10,
      );

      if (!mounted) return;

      setState(() {
        _performanceHistory = recentHistory;
        _recentPerformanceSpots = [];
        _recentPerformanceDates = [];

        for (int i = 0; i < _performanceHistory.length; i++) {
          final entry = _performanceHistory[i];
          _recentPerformanceSpots.add(
            FlSpot(i.toDouble(), (entry['score'] as int).toDouble()),
          );
          _recentPerformanceDates.add(DateTime.parse(entry['date']));
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your stats...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isSmallScreen,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 30.0 : 40.0, color: color),
            SizedBox(height: isSmallScreen ? 5.0 : 10.0),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 16.0 : 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 12.0 : 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _error != null
          ? _buildErrorWidget()
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenWidth < 600;
                final padding = isSmallScreen ? 8.0 : 16.0;
                final crossAxisCount = isSmallScreen ? 2 : 4;
                final chartHeight = isSmallScreen ? 150.0 : 200.0;

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
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
                              padding: EdgeInsets.all(padding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your Point this Week',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16.0 : 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$_lifetimePoints Pt',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16.0 : 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? 10.0 : 20.0),
                                  if (_recentPerformanceSpots.isNotEmpty)
                                    SizedBox(
                                      height: chartHeight,
                                      child: LineChart(
                                        LineChartData(
                                          gridData: const FlGridData(
                                            show: false,
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                          ? 10
                                                          : 12,
                                                    ),
                                                  );
                                                },
                                                interval: 5,
                                                reservedSize: isSmallScreen
                                                    ? 30
                                                    : 40,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  if (value.toInt() <
                                                      _recentPerformanceDates
                                                          .length) {
                                                    final DateTime date =
                                                        _recentPerformanceDates[value
                                                            .toInt()];
                                                    return SideTitleWidget(
                                                      axisSide: meta.axisSide,
                                                      child: Text(
                                                        DateFormat(
                                                          'MMM dd',
                                                        ).format(date),
                                                        style: TextStyle(
                                                          fontSize:
                                                              isSmallScreen
                                                              ? 8
                                                              : 10,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                                reservedSize: isSmallScreen
                                                    ? 20
                                                    : 30,
                                                interval: 1,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
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
                                              (_recentPerformanceSpots.length -
                                                      1)
                                                  .toDouble(),
                                          minY: 0,
                                          maxY: 20,
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: _recentPerformanceSpots,
                                              isCurved: true,
                                              color: Colors.deepPurpleAccent,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: const FlDotData(
                                                show: false,
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: Colors.deepPurpleAccent
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          'No performance data available yet',
                                          style: TextStyle(
                                            fontSize: isSmallScreen
                                                ? 14.0
                                                : 16.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20.0 : 30.0),
                          Text(
                            'Your Achievements',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18.0 : 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 10.0 : 20.0),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: padding,
                            mainAxisSpacing: padding,
                            childAspectRatio: isSmallScreen ? 1.2 : 1.0,
                            children: [
                              _buildAchievementCard(
                                Icons.question_answer,
                                '$_totalQuizzes',
                                'Quizzes Taken',
                                Colors.deepPurpleAccent,
                                isSmallScreen,
                              ),
                              _buildAchievementCard(
                                Icons.monetization_on,
                                '$_lifetimePoints',
                                'Lifetime Point',
                                Colors.orangeAccent,
                                isSmallScreen,
                              ),
                              _buildAchievementCard(
                                Icons.local_fire_department,
                                '$_quizzesPassed',
                                'Quiz Passed',
                                Colors.redAccent,
                                isSmallScreen,
                              ),
                              _buildAchievementCard(
                                Icons.emoji_events,
                                '$_perfectScores',
                                'Perfect Scores',
                                Colors.amber,
                                isSmallScreen,
                              ),
                            ],
                          ),
                          if (_performanceHistory.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: isSmallScreen ? 15.0 : 20.0),
                                Text(
                                  'Recent Quiz Performance',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 18.0 : 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 10.0 : 20.0),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _performanceHistory.length,
                                  itemBuilder: (context, index) {
                                    final entry = _performanceHistory[index];
                                    final DateTime date = DateTime.parse(
                                      entry['date'],
                                    );
                                    final String formattedDate = DateFormat(
                                      'MMM dd, yyyy - hh:mm a',
                                    ).format(date);
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 0.0,
                                        vertical: isSmallScreen ? 4.0 : 8.0,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          'Theme: ${entry['quiz_theme']}',
                                          style: TextStyle(
                                            fontSize: isSmallScreen
                                                ? 14.0
                                                : 16.0,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Score: ${entry['score']}/${entry['total_questions']}\nDate: $formattedDate',
                                          style: TextStyle(
                                            fontSize: isSmallScreen
                                                ? 12.0
                                                : 14.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
