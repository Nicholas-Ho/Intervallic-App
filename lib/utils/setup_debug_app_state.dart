import 'dart:async';

import 'package:intervallic_app/utils/local_notifications_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:intervallic_app/models/models.dart';
import 'data_layer/db_helper.dart';

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
        intervalType: IntervalType.weeks,
        nextDate: DateTime.now().add(Duration(days: 3)),
        description: null);
    
    Reminder cleanHouse = Reminder(
        id: 2,
        name: "Clean the House",
        reminderGroupID: 1,
        intervalValue: 2,
        intervalType: IntervalType.weeks,
        nextDate: DateTime.now().subtract(Duration(days: 3)),
        description: null);

    Reminder nelson = Reminder(
        id: 3,
        name: "Call Nelson",
        reminderGroupID: 2,
        intervalValue: 1,
        intervalType: IntervalType.months,
        nextDate: DateTime.now().add(Duration(days: 3)),
        description: null);

    await dataLayer.newEntryToDB('reminders', doYoga.toMap());
    await dataLayer.newEntryToDB('reminders', cleanHouse.toMap());
    await dataLayer.newEntryToDB('reminders', nelson.toMap());
  }

  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'reminders_database.db');
  await deleteDatabase(path);

  await addData();
}

Future<void> clearNotifications() async {
  LocalNotificationService().init();
  await LocalNotificationService().clearAll();
}