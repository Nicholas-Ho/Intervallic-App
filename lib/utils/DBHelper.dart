import 'dart:async';


import 'package:intervallic_app/models/models.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Database Helper class for SQLite databse
class DBHelper {
  DBHelper._();
  static final DBHelper db = DBHelper._(); // Database is a singleton

  static Database _database;

  // Lazy getter for database
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  // Opening the database connection. Hard-coded onCreate. Foreign Keys enabled.
  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'reminders_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reminder_groups
          (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE reminders
          (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            reminder_group_id INTEGER,
            interval INTEGER NOT NULL,
            last_done INTEGER NOT NULL,
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

    var id = await db.insert(databaseName, entry);

    return id;
  }

  // General Function to query database
  Future<List<Map<String, dynamic>>> queryDatabase(String table, {List<String> columns, String whereColumn, String whereArg}) async {
    final db = await database;

    if (whereColumn != null && whereArg != null) {
      String whereString = "$whereColumn = ?";
      List<Object> whereArgsList = [whereArg];
      return await db.query(
        table,
        columns: columns,
        where: whereString,
        whereArgs: whereArgsList,
      );
    } else {
      return await db.query(
        table,
        columns: columns);
    }
  }

  // Update a database entry (by id)
  updateEntryToDB(String databaseName, Map<String, dynamic> entry) async {
    final db = await database;

    var id = await db.update(databaseName,
      entry,
      where: 'id = ?',
      whereArgs: entry['id']);

    return id;
  }

  // Delete a database entry (by id)
  deleteFromDB(String databaseName, Map<String, dynamic> entry) async {
    final db = await database;

    var id = await db.delete(databaseName,
      where: 'id = ?',
      whereArgs: entry['id']);

    return id;
  }

  // Helper function for resetting the existing database and setting up the test database
  Future<void> setupDebugDatabase() async {
    Future<void> addData() async {
      ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
      ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
      ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");

      await newEntryToDB('reminder_groups', dailyReminders.toMap());
      await newEntryToDB('reminder_groups', keepInTouch.toMap());
      await newEntryToDB('reminder_groups', miscellaneous.toMap());

      Reminder doYoga = Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 1,
          interval: 100,
          lastDone: 100,
          description: null);
      
      Reminder waterPlants = Reminder(
          id: 2,
          name: "Water the Plants",
          reminderGroupID: 1,
          interval: 100,
          lastDone: 100,
          description: null);

      Reminder nelson = Reminder(
          id: 3,
          name: "Call Nelson",
          reminderGroupID: 2,
          interval: 100,
          lastDone: 100,
          description: null);

      await newEntryToDB('reminders', doYoga.toMap());
      await newEntryToDB('reminders', waterPlants.toMap());
      await newEntryToDB('reminders', nelson.toMap());
    }

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'reminders_database.db');
    await deleteDatabase(path);

    await addData();
  }
}
