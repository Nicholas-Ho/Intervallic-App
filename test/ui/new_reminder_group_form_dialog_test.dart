import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/ui/dialogs/reminder_group_dialogs/new_reminder_group_form_dialog.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';

void main () {
  MockReminderDataState mockReminderDataState = MockReminderDataState();
  // SetUp and TearDown not required

  testWidgets('Test for emtpy form layout', (WidgetTester tester) async {
    // Set-up
    await tester.pumpWidget(
      ChangeNotifierProvider<ReminderDataState>.value(
        value: mockReminderDataState, // Provider of Mock Reminder Data State
        builder: (context, _) {
          return _wrapDialogWithMaterialApp(NewReminderGroupFormDialog());
        }
      )
    );

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    // Check empty form layout
    final titleFinder = find.text('New Reminder Group');
    final nameTextFieldFinder = find.text('Name');
    final submitButtonFinder = find.text('OK');

    expect(titleFinder, findsOneWidget);
    expect(nameTextFieldFinder, findsOneWidget);
    expect(submitButtonFinder, findsOneWidget);
  });

  testWidgets('Test for submitting empty form', (WidgetTester tester) async {
    // Set-up
    await tester.pumpWidget(
      ChangeNotifierProvider<ReminderDataState>.value(
        value: mockReminderDataState, // Provider of Mock Reminder Data State
        builder: (context, _) {
          return _wrapDialogWithMaterialApp(NewReminderGroupFormDialog());
        }
      )
    );

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Check errors thrown
    final nameTextFieldErrorFinder = find.text('Reminder Group name cannot be empty');

    expect(nameTextFieldErrorFinder, findsOneWidget);
  });

  testWidgets('Test for successful form submission', (WidgetTester tester) async {
    // Set-up
    await tester.pumpWidget(
      ChangeNotifierProvider<ReminderDataState>.value(
        value: mockReminderDataState, // Provider of Mock Reminder Data State
        builder: (context, _) {
         return _wrapDialogWithMaterialApp(NewReminderGroupFormDialog());
        }
      )
    );

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    // Fill in form
    final nameTextFieldFinder = find.byKey(Key('Reminder Group Name Text Field'));

    // Fill text
    await tester.enterText(nameTextFieldFinder, 'Habit Forming');

    // Submit form
    await tester.tap(find.text('OK'));
    await tester.pump(Duration(seconds: 2));

    expect(find.text('Reminder Group Created!'), findsOneWidget);

    // Ensure dialog is closed
    await tester.pumpAndSettle();
    expect(find.text('New Reminder Group'), findsNothing);
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
  @override
  newReminderGroup(ReminderGroup newReminderGroup) {
    print('Reminder Group "${newReminderGroup.name}" was successfully created!');
  }
}