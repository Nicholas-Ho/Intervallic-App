import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:intervallic_app/models/models.dart';
import 'db_helper.dart';

// Helper function for resetting the existing database and setting up the test database
Future<void> setupDebugDatabase() async {
  final dataLayer = DBHelper();
  Future<void> addData() async {
    ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
    ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
    ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");

    await dataLayer.newEntryToDB('reminder_groups', dailyReminders.toMap());
    await dataLayer.newEntryToDB('reminder_groups', keepInTouch.toMap());
    await dataLayer.newEntryToDB('reminder_groups', miscellaneous.toMap());

    Reminder doYoga = Reminder(
        id: 1,
        name: "Do Yoga",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: 'Weeks',
        nextDate: DateTime.now().add(Duration(days: 7)),
        description: null);
    
    Reminder waterPlants = Reminder(
        id: 2,
        name: "Water the Plants",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: 'Weeks',
        nextDate: DateTime.now().add(Duration(days: 7)),
        description: null);

    Reminder nelson = Reminder(
        id: 3,
        name: "Call Nelson",
        reminderGroupID: 2,
        intervalValue: 1,
        intervalType: 'Weeks',
        nextDate: DateTime.now().add(Duration(days: 7)),
        description: null);

    await dataLayer.newEntryToDB('reminders', doYoga.toMap());
    await dataLayer.newEntryToDB('reminders', waterPlants.toMap());
    await dataLayer.newEntryToDB('reminders', nelson.toMap());
  }

  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'reminders_database.db');
  await deleteDatabase(path);

  await addData();
}