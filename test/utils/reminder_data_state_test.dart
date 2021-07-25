import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/utils/data_layer/db_helper.dart';
import 'package:intervallic_app/models/models.dart';

void main() {
  Map<String, List<Map<String, dynamic>>> testData = { // Initial mock database for all tests
    'reminder_groups': [
      {'id': 1, 'name': 'Daily Reminders'},
      {'id': 2, 'name': 'Keep In Touch'},
      {'id': 3, 'name': 'Miscellaneous'}
    ],
    'reminders': [
      {
        'id': 1,
        'name': "Do Yoga",
        'reminder_group_id': 1,
        'interval_value': 1,
        'interval_type': 'weeks',
        'next_date': 100,
        'description': null
      },
      {
        'id': 2,
        'name': "Water the Plants",
        'reminder_group_id': 1,
        'interval_value': 1,
        'interval_type': 'weeks',
        'next_date': 100,
        'description': null
      },
      {
        'id': 3,
        'name': "Call Nelson",
        'reminder_group_id': 2,
        'interval_value': 1,
        'interval_type': 'weeks',
        'next_date': 100,
        'description': null
      }
    ]
  };

  group('Diagnostic test for MockDBHelper.', () {
    late MockDBHelper mockDBHelper;

    setUp(() {
      mockDBHelper = MockDBHelper();
      mockDBHelper.mockData = testData;
    });

    tearDown(() {}); // TearDown not required as mockDBHelper is reinitialised in setUp

    test('Test for queryDatabase.', () async {
      expect(await mockDBHelper.queryDatabase('reminder_groups'),
        [
          {'id': 1, 'name': 'Daily Reminders'},
          {'id': 2, 'name': 'Keep In Touch'},
          {'id': 3, 'name': 'Miscellaneous'}
        ]);

      expect(await mockDBHelper.queryDatabase('reminders', columns: ['name', 'reminder_group_id']),
        [
          {'name': 'Do Yoga', 'reminder_group_id': 1},
          {'name': 'Water the Plants', 'reminder_group_id': 1},
          {'name': 'Call Nelson', 'reminder_group_id': 2}
        ]);

      expect(await mockDBHelper.queryDatabase('reminders', columns: ['name'], whereColumn: 'reminder_group_id', whereArg: '1'),
        [
          {'name': 'Do Yoga'},
          {'name': 'Water the Plants'}
        ]);
    });

    test('Test for newEntryToDB', () async {
      Map<String, dynamic> entry = {
        'id': 4,
        'name': "Call Kexin",
        'reminder_group_id': 2,
        'interval_value': 1,
        'interval_type': 'weeks',
        'next_date': 100,
        'description': null
      };
      expect(await mockDBHelper.newEntryToDB('reminders', entry), 4);
    });

    test('Test for updateEntryToDB', () async {
      Map<String, dynamic> entry = {
        'id': 3,
        'name': "Call Yi Lei",
        'reminder_group_id': 2,
        'interval_value': 1,
        'interval_type': 'weeks',
        'next_date': 100,
        'description': null
      };
      expect(await mockDBHelper.updateEntryToDB('reminders', entry), 3);
    });

    test('Test for deleteFromDB', () async {
      Map<String, dynamic> entry = {
        'id': 3,
        'name': "Call Nelson",
        'reminder_group_id': 2,
        'interval_value': 1,
        'interval_type': 'weeks',
        'next_date': 100,
        'description': null
      };
      expect(await mockDBHelper.deleteFromDB('reminders', entry), 3);
    });
  });

  group('Tests for ReminderDataState methods for Reminders.', () {
    late ReminderDataState reminderDataState;
    MockDBHelper mockDBHelper;
    Map<ReminderGroup, List<Reminder>>? initialExpected;

    setUp(() {
      mockDBHelper = MockDBHelper();
      mockDBHelper.mockData = testData;

      reminderDataState = ReminderDataState();
      reminderDataState.dataLayer = mockDBHelper;

      // Setting up initial expected result
      ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
      ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
      ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");
      Reminder doYoga = Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null);
      Reminder waterPlants = Reminder(
          id: 2,
          name: "Water the Plants",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null);
      Reminder nelson = Reminder(
          id: 3,
          name: "Call Nelson",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null);

      initialExpected = {
        dailyReminders: [doYoga, waterPlants],
        keepInTouch: [nelson],
        miscellaneous: []
      };
    });

    tearDown(() {}); // TearDown not required as reminderDataState is reinitialised in setUp

    test('Test for lazy getter (_getDBData and _initIDManager)', () async { // Not duplicated in ReminderGroup test group
      expect(await reminderDataState.reminderData, initialExpected);
    });

    test('Test for newReminder', () async {
      await reminderDataState.newReminder( // Should have no effect and print a warning (Reminder Group does not exist)
        Reminder(
          id: 0,
          name: "Call Kexin",
          reminderGroupID: 5,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));

      await reminderDataState.newReminder(
        Reminder(
          id: 0,
          name: "Call Kexin",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));

      // Set up and check against expected result
      Map<ReminderGroup, List<Reminder>> expectedResult = initialExpected!;
      expectedResult[expectedResult.keys.elementAt(1)]!.add(
        Reminder(
          id: 4,
          name: "Call Kexin",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        )
      );
      expect(await reminderDataState.reminderData, expectedResult);
    });

    test('Test for updateReminder', () async {
      await reminderDataState.updateReminder( // Should have no effect and print a warning (Reminder does not exist)
        Reminder(
          id: 4,
          name: "Call Kexin",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));

      await reminderDataState.updateReminder( // Should have no effect and print a warning (Reminder Group does not exist)
        Reminder(
          id: 3,
          name: "Call Yi Lei",
          reminderGroupID: 5,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));

      await reminderDataState.updateReminder(
        Reminder(
          id: 3,
          name: "Call Yi Lei",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));

      // Set up and check against expected result
      Map<ReminderGroup, List<Reminder>> expectedResult = initialExpected!;
      expectedResult[expectedResult.keys.elementAt(1)]![0] =
        Reminder(
          id: 3,
          name: "Call Yi Lei",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        );
      expect(await reminderDataState.reminderData, expectedResult);
    });

    test('Test for deleteReminder', () async {
      await reminderDataState.deleteReminder( // Should have no effect and print a warning (Reminder does not exist)
        Reminder(
          id: 4,
          name: "Call Kexin",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));

      await reminderDataState.deleteReminder( // Should have no effect and print a warning (Reminder Group does not exist)
        Reminder(
          id: 2,
          name: "Water the Plants",
          reminderGroupID: 5,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));
      
      await reminderDataState.deleteReminder(
        Reminder(
          id: 2,
          name: "Water the Plants",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null
        ));

      // Set up and check against expected result
      Map<ReminderGroup, List<Reminder>> expectedResult = initialExpected!;
      expectedResult[expectedResult.keys.elementAt(0)]!.removeAt(1);
      expect(await reminderDataState.reminderData, expectedResult);
    });
  });

  group('Tests for ReminderDataState methods for Reminder Groups.', () {
    late ReminderDataState reminderDataState;
    MockDBHelper mockDBHelper;
    late Map<ReminderGroup, List<Reminder>> initialExpected;

    setUp(() {
      mockDBHelper = MockDBHelper();
      mockDBHelper.mockData = testData;

      reminderDataState = ReminderDataState();
      reminderDataState.dataLayer = mockDBHelper;

      // Setting up initial expected result
      ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
      ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
      ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");
      Reminder doYoga = Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null);
      Reminder waterPlants = Reminder(
          id: 2,
          name: "Water the Plants",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null);
      Reminder nelson = Reminder(
          id: 3,
          name: "Call Nelson",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: DateTime.fromMillisecondsSinceEpoch(100),
          description: null);

      initialExpected = {
        dailyReminders: [doYoga, waterPlants],
        keepInTouch: [nelson],
        miscellaneous: []
      };
    });

    tearDown(() {}); // TearDown not required as reminderDataState is reinitialised in setUp

    test('Test for newReminderGroup', () async {
      await reminderDataState.newReminderGroup(
        ReminderGroup(
          id: 0,
          name: "Preparing for UK Trip",
        ));

      // Set up and check against expected result
      Map<ReminderGroup, List<Reminder>> expectedResult = initialExpected;
      expectedResult[
        ReminderGroup(
          id: 4,
          name:  "Preparing for UK Trip",
        )
      ] = [];
      expect(await reminderDataState.reminderData, expectedResult);
    });

    test('Test for updateReminderGroup', () async {
      await reminderDataState.updateReminderGroup( // Should have no effect and print a warning (Reminder Group does not exist)
        ReminderGroup(
          id: 4,
          name: "Preparing for UK Trip",
        ));

      await reminderDataState.updateReminderGroup(
        ReminderGroup(
          id: 1,
          name: "Habit Forming",
        ));

      // Set up and check against expected result
      ReminderGroup habitForming = ReminderGroup(id: 1, name: "Habit Forming");
      ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
      ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");
      Map<ReminderGroup, List<Reminder>?> expectedResult = {
        habitForming: [],
        keepInTouch: [],
        miscellaneous: []
      };
      for(int i = 0; i < expectedResult.length; i++) {
        expectedResult[expectedResult.keys.elementAt(i)] = initialExpected[initialExpected.keys.elementAt(i)];
      }
      expect(await reminderDataState.reminderData, expectedResult);
    });

    test('Test for deleteReminderGroup', () async {
      await reminderDataState.deleteReminderGroup( // Should have no effect and print a warning (Reminder Group does not exist)
        ReminderGroup(
          id: 4,
          name: "Prepare for UK Trip"
        ));
      
      await reminderDataState.deleteReminderGroup(
        ReminderGroup(
          id: 2,
          name: "Keep In Touch"
        ));

      // Set up and check against expected result
      Map<ReminderGroup, List<Reminder>> expectedResult = initialExpected;
      expectedResult.remove(ReminderGroup(id: 2, name: "Keep In Touch"));
      expect(await reminderDataState.reminderData, expectedResult);
    });
  });
}

// Mock DBHelper
class MockDBHelper extends Mock implements DBHelper {
  late Map<String, List<Map<String, dynamic>>> mockData;

  @override
  Future<List<Map<String, dynamic>>> queryDatabase(String databaseName, {List<String>? columns, String? whereColumn, String? whereArg}) async {
    Map<String, dynamic> checkColumns(Map<String, dynamic> element, List<String>? columns) {
      if(columns != null){
        Map<String, dynamic> map = {};
        for(int i = 0; i < columns.length; i++) {
          map[columns[i]] = element[columns[i]];
        }
        return map;
      } else {
        return element;
      }
    }

    final reminders = mockData[databaseName];
    List<Map<String, dynamic>> results = [];

    if(whereColumn != null) {
      var whereArgFinal;
      try{
        whereArgFinal = int.parse(whereArg!);
      } on FormatException {
        whereArgFinal = whereArg;
      }
      reminders!.forEach((element) {
          if(element[whereColumn] == whereArgFinal) {
            results.add(checkColumns(element, columns));
          }
        });
    } else {
      reminders!.forEach((element) {
        results.add(checkColumns(element, columns));
      });
    }

    return Future.delayed(Duration(microseconds: 1), () => results);
  }

  @override
  newEntryToDB(String databaseName, Map<String, dynamic> entry) async {
    print('Entry "${entry['name']}" (id: ${entry['id']}) inserted into database "$databaseName"!');
    return entry['id'];
  }

  @override
  updateEntryToDB(String databaseName, Map<String, dynamic> entry) async {
    print('Entry "${entry['name']}" (id: ${entry['id']}) updated in database "$databaseName"!');
    return entry['id'];
  }

  @override
  deleteFromDB(String databaseName, Map<String, dynamic> entry) async {
    print('Entry "${entry['name']}" (id: ${entry['id']}) deleted from database "$databaseName"!');
    return entry['id'];
  }
}