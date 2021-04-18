import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:intervallic_app/models/models.dart';

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

  // Adding new Reminder Group to database
  newReminderGroup(ReminderGroup newGroup) async {
    final db = await database;

    var res = await db.rawInsert('''
      INSERT INTO reminder_groups(
        id, name
      ) VALUES (?, ?)
    ''', [newGroup.id, newGroup.name]);

    return res;
  }

  // Adding new Reminder to database
  newReminder(Reminder newReminder) async {
    final db = await database;

    var res = await db.rawInsert('''
      INSERT INTO reminders(
        id, name, reminder_group_id, interval, last_done, description
      ) VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      newReminder.id,
      newReminder.name,
      newReminder.reminderGroupID,
      newReminder.interval,
      newReminder.lastDone,
      newReminder.description
    ]);

    return res;
  }

  // General Function to query database
  Future<List<Map<String, dynamic>>> _queryDatabase(String table, [String whereColumn, String whereArg]) async {
    final db = await database;

    if (whereColumn != null && whereArg != null) {
      String whereString = "$whereColumn = ?";
      List<Object> whereArgsList = [whereArg];
      return await db.query(
        table,
        where: whereString,
        whereArgs: whereArgsList,
      );
    } else {
      return await db.query(table);
    }
  }

  // Query all Reminder Groups from database. Returns List of Reminder Groups
  Future<List<ReminderGroup>> getAllReminderGroups() async {
    final List<Map<String, dynamic>> maps =
        await _queryDatabase('reminder_groups');

    return List.generate(maps.length, (i) {
      return ReminderGroup(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  // Query Reminders by Reminder Group ID
  Future<List<Reminder>> getRemindersByGroup(int group) async {
    final List<Map<String, dynamic>> maps =
        await _queryDatabase('reminders', 'reminder_group_id', '$group');

    return List.generate(maps.length, (i) {
      return Reminder(
        id: maps[i]['id'],
        name: maps[i]['name'],
        reminderGroupID: maps[i]['reminder_group_id'],
        interval: maps[i]['interval'],
        lastDone: maps[i]['last_done'],
        description: maps[i]['description'],
      );
    });
  }

  /*Future<dynamic> getReminderGroup() async {
    final db = await database;

    var res = await db.query('user');
    if(res.length == 0) {
      return null;
    } else {
      var resMap = res[0];
      return resMap.isNotEmpty ? resMap : null;
    }
  }*/

  /*Future<List<Reminder>> getAllReminders() async {
    final List<Map<String, dynamic>> maps = await _queryDatabase('reminders');

    return List.generate(maps.length, (i) {
      return Reminder(
        id: maps[i]['id'],
        name: maps[i]['name'],
        reminderGroupID: maps[i]['reminder_group_id'],
        interval: maps[i]['interval'],
        lastDone: maps[i]['last_done'],
        description: maps[i]['description'],
      );
    });
  }*/
}
