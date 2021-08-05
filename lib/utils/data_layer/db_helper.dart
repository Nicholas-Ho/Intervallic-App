import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String reminderGroupTable = 'reminder_groups';
final String reminderTable = 'reminders';

// Database Helper class for SQLite databse
class DBHelper {
  DBHelper._(); // Private constructor
  static final DBHelper _dbHelperSingleton = DBHelper._(); // Database is a singleton

  factory DBHelper() { // Refactored for testing purposes (ReminderDataState test)
    return _dbHelperSingleton;
  }

  static Database? _database;

  // Lazy getter for database
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDB();
    return _database;
  }

  // Opening the database connection. Hard-coded onCreate. Foreign Keys enabled.
  _initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'reminders_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reminder_groups
          (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE reminders
          (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            reminder_group_id INTEGER,
            interval_value INTEGER NOT NULL,
            interval_type TEXT NOT NULL,
            next_date INTEGER NOT NULL,
            description TEXT,
            FOREIGN KEY (reminder_group_id)
              REFERENCES reminder_groups (id)
          );
        ''');
      },
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      version: 1,
    );
  }

  // Insert new entry into database
  newEntryToDB(String databaseName, Map<String, dynamic> entry) async {
    final db = await database;

    var id = await db!.insert(databaseName, entry);

    return id;
  }

  // General Function to query database
  Future<List<Map<String, dynamic>>> queryDatabase(String databaseName, {List<String>? columns, String? whereColumn, String? whereArg}) async {
    final db = await database;

    if (whereColumn != null && whereArg != null) {
      String whereString = "$whereColumn = ?";
      List<Object> whereArgsList = [whereArg];
      return await db!.query(
        databaseName,
        columns: columns,
        where: whereString,
        whereArgs: whereArgsList,
      );
    } else {
      return await db!.query(
        databaseName,
        columns: columns); // Passing null into columns will return all columns.
    }
  }

  // Update a database entry (by id)
  updateEntryToDB(String databaseName, Map<String, dynamic> entry) async {
    final db = await database;

    var id = await db!.update(
      databaseName,
      entry,
      where: 'id = ?',
      whereArgs:[entry['id']]);

    return id;
  }

  // Delete a database entry (by id)
  deleteFromDB(String databaseName, Map<String, dynamic> entry) async {
    final db = await database;

    var id = await db!.delete(
      databaseName,
      where: 'id = ?',
      whereArgs: [entry['id']]);

    return id;
  }
}
