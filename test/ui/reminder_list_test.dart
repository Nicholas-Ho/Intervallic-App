import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/ui/reminder_list/reminder_list.dart';
import 'package:intervallic_app/ui/reminder_list/tiles.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';

void main () {
  MockReminderDataState? mockReminderDataState;
  setUp(() {
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

    final Map<ReminderGroup, List<Reminder>> mockData = {
      dailyReminders: [doYoga, waterPlants],
      keepInTouch: [nelson],
      miscellaneous: []
    };
    mockReminderDataState = MockReminderDataState();
    mockReminderDataState!.mockData = mockData;
  });

  tearDown(() {}); // TearDown not required as mockReminderDataState is reinitialised in setUp

  testWidgets('Test for Reminder List generation', (WidgetTester tester) async {
    // Set-up
    await tester.pumpWidget(
      ChangeNotifierProvider<ReminderDataState?>.value(
        value: mockReminderDataState, // Provider of Mock Reminder Data State
        builder: (context, _) {
          return MaterialApp(
            home: Scaffold(
              body: ReminderList() // Widget to test
            )
          );
        }
      )
    );

    await tester.pump(Duration(milliseconds: 10));

    // Check result
    final reminderGroupTileFinder = find.byType(ReminderGroupTile);
    final reminderTileFinder = find.byType(ReminderTile);

    expect(reminderGroupTileFinder, findsNWidgets(3)); // Check Reminder Group Tiles and their text
    expect(find.text('Daily Reminders'), findsOneWidget);
    expect(find.text('Keep In Touch'), findsOneWidget);
    expect(find.text('Miscellaneous'), findsOneWidget);

    expect(find.text('Habit Forming'), findsNothing); // Negative test

    expect(reminderTileFinder, findsNWidgets(3)); // Check Reminder Tiles and their text
    expect(find.text('Do Yoga'), findsOneWidget);
    expect(find.text('Water the Plants'), findsOneWidget);
    expect(find.text('Call Nelson'), findsOneWidget);

    expect(find.text('Call Kexin'), findsNothing); // Negative test
  });
}

// Mock Reminder Data State
class MockReminderDataState extends Mock implements ReminderDataState {
  late Map<ReminderGroup, List<Reminder>> mockData;

  @override
  Future<Map<ReminderGroup, List<Reminder>>> get reminderData async {
    return Future.delayed(Duration(microseconds: 1), () => mockData);
  }
}