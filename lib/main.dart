import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'theme.dart';
import 'utils/domain_layer/reminder_data_state.dart';
import 'ui/reminder_list/reminder_list.dart';
import 'ui/dialogs/create_new_navigation_dialog.dart';
import 'utils/ui_layer/ui_reminder_group_manager.dart';

import 'utils/setup_debug_app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDebugDatabase(); // Deletes existing database on the phone and rebuilds it. Populates with test data
  await clearNotifications(); // Clears all existing local notifications

  return runApp(
    MultiProvider(
      providers: [
        // Change Notifier Provider for Reminder Data state management
        ChangeNotifierProvider(create: (context) => ReminderDataState()),
        // Change Notificer Provider for UI group management
        ChangeNotifierProvider(create: (context) => UIReminderGroupManager()),
      ],
      child: IntervallicApp(),
    )
  );
}

class IntervallicApp extends StatelessWidget {
  // The core of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intervallic',
      theme: intervallicTheme,
      home: IntervallicScaffold(), // Abstracting the Scaffold from the MaterialApp to ensure MaterialLocalizations works for showDialog
    );
  }
}

class IntervallicScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Intervallic", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: ReminderList(), // The to-do list
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return CreateNewNavigationDialog();
            }
            );
        },
      ),
    );
  }
}
