import 'package:flutter_test/flutter_test.dart';

import 'package:intervallic_app/models/models.dart';

void main() {
  group('Tests for Reminder Group.', () {
    ReminderGroup reminderGroup;
    setUp(() {
      reminderGroup = ReminderGroup(id: 1, name: "Daily Reminders");
    });

    tearDown(() {}); // TearDown not required as reminderGroup is reinstantiated in setUp

    test('Base test.', () {
      expect(reminderGroup.id, 1);
      expect(reminderGroup.name, 'Daily Reminders');
    });

    test('Test for setID', () {
      reminderGroup = reminderGroup.setID(5);

      // Check result
      expect(reminderGroup.id, 5);
      expect(reminderGroup.name, 'Daily Reminders');

    });

    test('Test for toMap', () {
      final Map<String, dynamic> resultMap = {
        'id': 1,
        'name': 'Daily Reminders'
      };

      // Check result
      expect(reminderGroup.toMap(), resultMap);
    });

    test('Test for fromMap', () {
      final Map<String, dynamic> sourceMap = {
        'id': 2,
        'name': 'Keep In Touch'
      };

      // Check result
      expect(ReminderGroup.fromMap(sourceMap), ReminderGroup(id: 2, name: 'Keep In Touch'));
    });
  });

  group('Tests for Reminder.', () {
    Reminder reminder;
    setUp(() {
      reminder = Reminder(
        id: 1,
        name: "Do Yoga",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: 'Weeks',
        nextDate: DateTime.fromMillisecondsSinceEpoch(100),
        description: null);
    });

    tearDown(() {}); // TearDown not required as reminderGroup is reinstantiated in setUp

    test('Base test.', () {
      expect(reminder.id, 1);
      expect(reminder.name, 'Do Yoga');
      expect(reminder.reminderGroupID, 1);
      expect(reminder.intervalValue, 1);
      expect(reminder.intervalType, 'Weeks');
      expect(reminder.nextDate, DateTime.fromMillisecondsSinceEpoch(100));
      expect(reminder.description, null);
    });

    test('Test for setID', () {
      reminder = reminder.setID(5);

      // Check result
      expect(reminder.id, 5);
      expect(reminder.name, 'Do Yoga');
      expect(reminder.reminderGroupID, 1);
      expect(reminder.intervalValue, 1);
      expect(reminder.intervalType, 'Weeks');
      expect(reminder.nextDate, DateTime.fromMillisecondsSinceEpoch(100));
      expect(reminder.description, null);
    });

    test('Test for getNewNextDate', () {
      // Set up
      DateTime now = DateTime.fromMillisecondsSinceEpoch(100);

      // Run function
      reminder = reminder.getNewNextDate(now);

      // Check result
      DateTime expectedDateTime = DateTime(now.year, now.month, now.day + 7, 8); // 7 days after the epoch, at 8am

      expect(reminder.id, 1);
      expect(reminder.name, 'Do Yoga');
      expect(reminder.reminderGroupID, 1);
      expect(reminder.intervalValue, 1);
      expect(reminder.intervalType, 'Weeks');
      expect(reminder.nextDate, expectedDateTime); // 604800000 milliseconds in a week
      expect(reminder.description, null);
    });

    test('Test for toMap', () {
      final Map<String, dynamic> resultMap = {
        'id': 1,
        'name': "Do Yoga",
        'reminder_group_id': 1,
        'interval_value': 1,
        'interval_type': 'Weeks',
        'next_date': 100,
        'description': null
      };

      // Check result
      expect(reminder.toMap(), resultMap);
    });

    test('Test for fromMap', () {
      final Map<String, dynamic> sourceMap = {
        'id': 2,
        'name': "Water the Plants",
        'reminder_group_id': 1,
        'interval_value': 1,
        'interval_type': 'Weeks',
        'next_date': 100,
        'description': null
      };

      // Check result
      Reminder resultReminder = Reminder(
        id: 2,
        name: "Water the Plants",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: 'Weeks',
        nextDate: DateTime.fromMillisecondsSinceEpoch(100),
        description: null
      );
      expect(Reminder.fromMap(sourceMap), resultReminder);
    });
  });
}