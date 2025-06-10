// ignore_for_file: depend_on_referenced_packages

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'quizo_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pseudo_name TEXT UNIQUE,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE performance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        quiz_theme TEXT,
        score INTEGER,
        total_questions INTEGER,
        date TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE performance ADD COLUMN total_questions INTEGER DEFAULT 0',
      );
    }
  }

  // User CRUD operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByPseudoName(String pseudoName) async {
    Database db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'pseudo_name = ?',
      whereArgs: [pseudoName],
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // Performance CRUD operations
  Future<int> insertPerformance(Map<String, dynamic> performance) async {
    Database db = await database;
    return await db.insert('performance', performance);
  }

  Future<List<Map<String, dynamic>>> getPerformanceByUser(
    int userId, {
    int? limit,
  }) async {
    Database db = await database;
    return await db.query(
      'performance',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> getOverallQuizStatistics(int userId) async {
    Database db = await database;

    // Calculate total quizzes taken
    int totalQuizzes =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM performance WHERE user_id = ?',
            [userId],
          ),
        ) ??
        0;

    // Calculate lifetime points
    int lifetimePoints =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(score) FROM performance WHERE user_id = ?',
            [userId],
          ),
        ) ??
        0;

    // Calculate quizzes passed (score >= 50% of total_questions)
    int quizzesPassed =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM performance WHERE user_id = ? AND score >= (total_questions / 2)',
            [userId],
          ),
        ) ??
        0;

    // Calculate perfect scores (score == total_questions)
    int perfectScores =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM performance WHERE user_id = ? AND score = total_questions',
            [userId],
          ),
        ) ??
        0;

    return {
      'total_quizzes': totalQuizzes,
      'lifetime_points': lifetimePoints,
      'quizzes_passed': quizzesPassed,
      'perfect_scores': perfectScores,
    };
  }
}
