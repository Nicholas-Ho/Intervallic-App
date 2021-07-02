import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/ui/create_new_navigation_dialog.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';

void main () {
  // SetUp and TearDown not required

  testWidgets('Test for layout', (WidgetTester tester) async {
    // Set-up
    await tester.pumpWidget(_wrapDialogWithMaterialApp(CreateNewNavigationDialog()));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    // Checklayout
    final newReminderGroupButtonFinder = find.text('New Reminder Group');
    final newReminderButtonFinder = find.text('New Reminder');

    expect(newReminderGroupButtonFinder, findsOneWidget);
    expect(newReminderButtonFinder, findsOneWidget);
  });

  testWidgets('Test for navigation to New Reminder Group Form', (WidgetTester tester) async {
    // Set-up
    await tester.pumpWidget(_wrapDialogWithMaterialApp(CreateNewNavigationDialog()));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    // Open New Reminder Group Form
    await tester.tap(find.text('New Reminder Group'));
    await tester.pumpAndSettle();

    // Check if New Reminder Group Form is open
    final titleFinder = find.text('New Reminder Group');
    final nameTextFieldFinder = find.text('Name');
    final submitButtonFinder = find.text('Add');

    expect(titleFinder, findsOneWidget);
    expect(nameTextFieldFinder, findsOneWidget);
    expect(submitButtonFinder, findsOneWidget);
    
    // Ensure Create New Navigation Dialog is closed
    final newReminderButtonFinder = find.text('New Reminder');
    expect(newReminderButtonFinder, findsNothing);
  });

  testWidgets('Test for navigation to New Reminder Form', (WidgetTester tester) async {
    // Setting up mock data fore New Reminder Form
    final Map<ReminderGroup, List<Reminder>> mockData = {
      ReminderGroup(id: 1, name: "Daily Reminders"): [],
      ReminderGroup(id: 2, name: "Keep In Touch"): [],
      ReminderGroup(id: 3, name: "Miscellaneous"): []
    };
    MockReminderDataState mockReminderDataState = MockReminderDataState();
    mockReminderDataState.mockData = mockData;

    // Set-up
    await tester.pumpWidget(
      ChangeNotifierProvider<ReminderDataState>.value(
        value: mockReminderDataState, // Provider of Mock Reminder Data State
        builder: (context, _) {
          return _wrapDialogWithMaterialApp(CreateNewNavigationDialog());
        }
      ));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    // Open New Reminder Group Form
    await tester.tap(find.text('New Reminder'));
    await tester.pumpAndSettle();

    // Check if New Reminder Form is open
    final nameTextFieldFinder = find.text('Name');
      final reminderGroupDropdownFinder = find.text('Reminder Group');
      final intervalSelectorTextFinder = find.text('Interval');
      final intervalSelectorDropdownFinder = find.text('Weeks');
      final startDatePickerFinder = find.text(DateFormat('dd/MM/yyyy').format(DateTime.now())); // No error message as the field defaults to Datetime.now()
      final startDatePickerTextFinder = find.text('Start Date');
      final submitButtonFinder = find.text('Add');

      expect(nameTextFieldFinder, findsOneWidget);
      expect(reminderGroupDropdownFinder, findsOneWidget);
      expect(intervalSelectorTextFinder, findsOneWidget);
      expect(intervalSelectorDropdownFinder, findsOneWidget);
      expect(startDatePickerFinder, findsOneWidget);
      expect(startDatePickerTextFinder, findsOneWidget);
      expect(submitButtonFinder, findsOneWidget);

      // Ensure Create New Navigation Dialog is closed
    final newReminderGroupButtonFinder = find.text('New Reminder Group');
    expect(newReminderGroupButtonFinder, findsNothing);
  });
}

Widget _wrapDialogWithMaterialApp (Widget dialog) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              child: Text('X'),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => dialog
            ));
          }
        )
      )
    )
  );
}

// Mock Reminder Data State
class MockReminderDataState extends Mock implements ReminderDataState {
  Map<ReminderGroup, List<Reminder>> mockData;

  @override
  Future<Map<ReminderGroup, List<Reminder>>> get reminderData async {
    return Future.delayed(Duration(microseconds: 1), () => mockData);
  }
}