// ignore_for_file: prefer_is_empty, unnecessary_brace_in_string_interps, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quizo_app/database_helper.dart';
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
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _performanceHistory = [];
  bool _isLoading = true;

  // Split loading into stages
  bool _statsLoaded = false;
  bool _chartLoaded = false;
  bool _historyLoaded = false;

  // Data variables
  int _lifetimePoints = 0;
  int _quizzesPassed = 0;
  int _perfectScores = 0;
  Map<String, dynamic>? _overallStats;
  List<FlSpot> _recentPerformanceSpots = [];
  List<DateTime> _recentPerformanceDates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load critical stats first (what user sees immediately)
    final overallStats = await _databaseHelper.getOverallQuizStatistics(
      widget.userId,
    );

    setState(() {
      _overallStats = overallStats;
      _lifetimePoints = overallStats['lifetime_points'] ?? 0;
      _quizzesPassed = overallStats['quizzes_passed'] ?? 0;
      _perfectScores = overallStats['perfect_scores'] ?? 0;
      _statsLoaded = true;
    });

    // Then load chart data
    final recentHistory = await _databaseHelper.getPerformanceByUser(
      widget.userId,
      limit: 10,
    );

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
      _chartLoaded = true;
    });

    // Finally load full history (lazy load if needed)
    if (_performanceHistory.isEmpty) {
      final fullHistory = await _databaseHelper.getPerformanceByUser(
        widget.userId,
      );
      setState(() {
        _performanceHistory = fullHistory;
        _historyLoaded = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _historyLoaded = true;
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
          if (_statsLoaded) const Text('✓ Basic stats loaded'),
          if (_chartLoaded) const Text('✓ Chart data loaded'),
          if (_historyLoaded) const Text('✓ History loaded'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 30.0),
            _buildAchievementsSection(),
            const SizedBox(height: 20.0),
            if (_performanceHistory.isNotEmpty)
              _buildRecentPerformanceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Points this Week',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
              child: _chartLoaded
                  ? LineChart(_buildChartData())
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
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
            interval: _lifetimePoints > 0
                ? (_lifetimePoints / 5).ceilToDouble()
                : 200,
            reservedSize: 40,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < _recentPerformanceDates.length) {
                final DateTime date = _recentPerformanceDates[value.toInt()];
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
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX:
          (_recentPerformanceSpots.length > 0
                  ? _recentPerformanceSpots.length - 1
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
            color: Colors.deepPurpleAccent.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              '${_overallStats?['total_quizzes'] ?? 0}',
              'Quizzes Taken',
              Colors.deepPurpleAccent,
            ),
            _buildAchievementCard(
              Icons.monetization_on,
              '${_lifetimePoints}',
              'Lifetime Points',
              Colors.orangeAccent,
            ),
            _buildAchievementCard(
              Icons.local_fire_department,
              '${_quizzesPassed}',
              'Quizzes Passed',
              Colors.redAccent,
            ),
            _buildAchievementCard(
              Icons.emoji_events,
              '${_perfectScores}',
              'Perfect Scores',
              Colors.amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Quiz Performance',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: min(
            5,
            _performanceHistory.length,
          ), // Show only 5 initially
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
        if (_performanceHistory.length > 5)
          TextButton(
            onPressed: () {
              // Navigate to full history screen
            },
            child: const Text('View Full History'),
          ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Statistics'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildMainContent(),
    );
  }
}

// Login and registration header

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background wave shape
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF673AB7), // Darker Purple
                  Color(0xFF8E24AA), // Lighter Purple
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Content (Logo and Title)
        SizedBox(
          height: 250,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // [MB] Logo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    '[Quizzo]',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title with decorative shapes
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Clipper for the wave effect
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50); // Start from bottom-left corner
    var controlPoint1 = Offset(size.width / 4, size.height);
    var endPoint1 = Offset(size.width / 2, size.height - 50);
    path.quadraticBezierTo(
      controlPoint1.dx,
      controlPoint1.dy,
      endPoint1.dx,
      endPoint1.dy,
    );

    var controlPoint2 = Offset(size.width * 3 / 4, size.height - 100);
    var endPoint2 = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint2.dx,
      endPoint2.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
