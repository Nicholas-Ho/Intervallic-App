import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/ui/new_reminder_form_dialog.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';

void main () {
  MockReminderDataState mockReminderDataState;
  setUp(() {
    // Setting up mock data
    // New Reminder Form Dialog only requires Reminder Groups, not Reminders
    final Map<ReminderGroup, List<Reminder>> mockData = {
      ReminderGroup(id: 1, name: "Daily Reminders"): [],
      ReminderGroup(id: 2, name: "Keep In Touch"): [],
      ReminderGroup(id: 3, name: "Miscellaneous"): []
    };
    mockReminderDataState = MockReminderDataState();
    mockReminderDataState.mockData = mockData;
  });

  tearDown(() {}); // TearDown not required as mockReminderDataState is reinitialised in setUp

  group('Tests for New Reminder Form Dialog (no date picker tests).', () {
    testWidgets('Test for emtpy form layout', (WidgetTester tester) async {
      // Set-up
      await tester.pumpWidget(
        ChangeNotifierProvider<ReminderDataState>.value(
          value: mockReminderDataState, // Provider of Mock Reminder Data State
          builder: (context, _) {
          return _wrapDialogWithMaterialApp(NewReminderFormDialog());
          }
        )
      );

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      // Check empty form layout
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
    });

    testWidgets('Test for submitting empty form', (WidgetTester tester) async {
      // Set-up
      await tester.pumpWidget(
        ChangeNotifierProvider<ReminderDataState>.value(
          value: mockReminderDataState, // Provider of Mock Reminder Data State
          builder: (context, _) {
            return _wrapDialogWithMaterialApp(NewReminderFormDialog());
          }
        )
      );

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Check errors thrown
      final nameTextFieldErrorFinder = find.text('Reminder name cannot be empty');
      final reminderGroupDropdownErrorFinder = find.text('Reminder Group cannot be empty');
      final intervalSelectorErrorFinder = find.text('Interval length cannot be empty');
      final startDatePickerFinder = find.text(DateFormat('dd/MM/yyyy').format(DateTime.now())); // No error message as the field defaults to Datetime.now()

      expect(nameTextFieldErrorFinder, findsOneWidget);
      expect(reminderGroupDropdownErrorFinder, findsOneWidget);
      expect(intervalSelectorErrorFinder, findsOneWidget);
      expect(startDatePickerFinder, findsOneWidget);
    });

    testWidgets('Test for successful form submission (no date picker test)', (WidgetTester tester) async {
      // Set-up
      await tester.pumpWidget(
        ChangeNotifierProvider<ReminderDataState>.value(
          value: mockReminderDataState, // Provider of Mock Reminder Data State
          builder: (context, _) {
            return _wrapDialogWithMaterialApp(NewReminderFormDialog());
          }
        )
      );

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      // Fill in form
      final nameTextFieldFinder = find.byKey(Key('Reminder Name Text Field'));
      final reminderGroupDropdownFinder = find.byKey(Key('Reminder Group Dropdown'));
      final intervalSelectorTextFinder = find.byKey(Key('Interval Selector Text Field'));
      final intervalSelectorDropdownFinder = find.byKey(Key('Interval Selector Dropdown'));

      // Fill text
      await tester.enterText(nameTextFieldFinder, 'Call Kexin');
      await tester.enterText(intervalSelectorTextFinder, '1');

      // Fill dropdowns

      // DropdownButton is made up of an IndexedStack, so even when the menu is not displayed the option widgets are present
      // eg. There is one instance of Text('Keep In Touch') when the DropdownButton menu is closed
      //     and two  instances of Text('Keep In Touch') when the DropdownButton menu is open
      // Hence, find.byKey(Key('Text here')).last is needed to refer to the DropdownButton menu option.
      await tester.tap(reminderGroupDropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('Keep In Touch')).last);
      await tester.pumpAndSettle();
      await tester.tap(intervalSelectorDropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('Days')).last);
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Add'));
      await tester.pump(Duration(seconds: 2));

      expect(find.text('Reminder Added!'), findsOneWidget);

      // Ensure dialog is closed
      await tester.pumpAndSettle();
      expect(find.text('New Reminder'), findsNothing);
    });
  });

  testWidgets('Test for date picker only', (WidgetTester tester) async {
    final now = DateTime.now();
    final yearFromNow = DateTime(now.year + 1, now.month, now.day);
    final yearFromNowString = DateFormat('MM/dd/yyyy').format(yearFromNow); // TEMP FIX: DATE PICKER USES MMDDYYYY ONLY
    final testDate = DateTime(now.year + 1, now.month, 1);
    final testDateString = DateFormat('dd/MM/yyyy').format(testDate);
    print(testDateString);

    // Set-up
    await tester.pumpWidget(
      ChangeNotifierProvider<ReminderDataState>.value(
        value: mockReminderDataState, // Provider of Mock Reminder Data State
        builder: (context, _) {
          return _wrapDialogWithMaterialApp(NewReminderFormDialog());
        }
      )
    );

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    // Open Date Picker
    final startDatePickerFinder = find.byKey(Key('Date Picker Text Field'));

    await tester.tap(startDatePickerFinder);
    await tester.pumpAndSettle();

    // Check if Date Picker is open
    expect(find.text('SELECT DATE'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);

    // Open date picker text mode
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // Edit date picker via text (to DateTime.now() + 1 year)
    tester.testTextInput.enterText(yearFromNowString);
    
    // Return to date picker calendar mode
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    // Edit date via date picker calendar (to the 1st of the selected month and year)
    await tester.tap(find.text('1'));
    await tester.pump();

    // Exit date picker
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Ensure date picker is closed
    expect(find.text('SELECT DATE'), findsNothing);
    expect(find.byIcon(Icons.edit), findsNothing);

    // Check if final date is correct
    expect(find.text(testDateString), findsOneWidget);

    // Check absolute value of TextField text
    // final startDatePickerTextField = startDatePickerFinder.evaluate().single.widget as TextFormField;
    // print(startDatePickerTextField.controller.text);
  });

  group('Tests for New Reminder Form Dialog (no date picker tests).', () {
    testWidgets('Test for successful form submission (with date picker test)', (WidgetTester tester) async {
      final now = DateTime.now();
      final yearFromNow = DateTime(now.year + 1, now.month, now.day);
      final yearFromNowString = DateFormat('MM/dd/yyyy').format(yearFromNow); // TEMP FIX: DATE PICKER USES MMDDYYYY ONLY
      final testDate = DateTime(now.year + 1, now.month, 1);
      final testDateString = DateFormat('dd/MM/yyyy').format(testDate);
      print(testDateString);
      // Set-up
      await tester.pumpWidget(
        ChangeNotifierProvider<ReminderDataState>.value(
          value: mockReminderDataState, // Provider of Mock Reminder Data State
          builder: (context, _) {
            return _wrapDialogWithMaterialApp(NewReminderFormDialog());
          }
        )
      );

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      // Fill in form
      final nameTextFieldFinder = find.byKey(Key('Reminder Name Text Field'));
      final reminderGroupDropdownFinder = find.byKey(Key('Reminder Group Dropdown'));
      final intervalSelectorTextFinder = find.byKey(Key('Interval Selector Text Field'));
      final intervalSelectorDropdownFinder = find.byKey(Key('Interval Selector Dropdown'));

      // Fill text
      await tester.enterText(nameTextFieldFinder, 'Call Kexin');
      await tester.enterText(intervalSelectorTextFinder, '2'); // Ensuring no clash with date picker test later

      // Fill dropdowns
      await tester.tap(reminderGroupDropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('Keep In Touch')).last);
      await tester.pumpAndSettle();
      await tester.tap(intervalSelectorDropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('Days')).last);
      await tester.pumpAndSettle();

      // Fill date picker
      final startDatePickerFinder = find.byKey(Key('Date Picker Text Field'));

      await tester.tap(startDatePickerFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      tester.testTextInput.enterText(yearFromNowString);
      
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Add'));
      await tester.pump(Duration(seconds: 2));

      expect(find.text('Reminder Added!'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('New Reminder'), findsNothing);
    });
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

  @override
  newReminder(Reminder newReminder) {
    print('Reminder "${newReminder.name}" was successfully created!');
  }
}