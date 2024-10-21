import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'library.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY,
        title TEXT,
        author TEXT,
        description TEXT,
        disponible INTEGER,
        reservation_start_date TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE books ADD COLUMN description TEXT;
      ''');
      await db.execute('''
        ALTER TABLE books ADD COLUMN disponible INTEGER;
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE books ADD COLUMN reservation_start_date TEXT;
      ''');
    }
  }

  Future<int> insertBook(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('books', row);
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await database;
    return await db.query('books');
  }

  Future<int> updateBook(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'books',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getDatabaseSize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'library.db');
    final file = File(path);
    return await file.length();
  }

  Future<void> deleteAllBooks() async {
    final db = await database;
    await db.delete('books');
  }

  Future<bool> isTableEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM books'));
    return count == 0;
  }

  Future<int> updateBookAvailability(int bookId, bool isAvailable, String? datereservation) async {
    final db = await database;
    return await db.update(
      'books',
      {
      'disponible': isAvailable ? 1 : 0,
      'reservation_start_date': datereservation,
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<List<Map<String, dynamic>>> getReservedBooks() async {
    final db = await database;
    return await db.query('books', where: 'disponible = ?', whereArgs: [0]);
  }
}



