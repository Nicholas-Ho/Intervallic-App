import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'theme.dart';
import 'utils/domain_layer/reminder_data_state.dart';
import 'ui/reminder_list.dart';
import 'ui/create_new_navigation_dialog.dart';

import 'utils/data_layer/setup_debug_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDebugDatabase(); // Deletes existing database on the phone and rebuilds it. Populates with test data

  return runApp(
    ChangeNotifierProvider(
      // Change Notifier Provider for Reminder Data state management
      create: (context) => ReminderDataState(),
      child: IntervallicApp(),
    ),
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
        backgroundColor: Theme.of(context).primaryColorLight,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text("Intervallic"),
      ),
      body: ReminderList(), // The to-do list
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: Colors.white,
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
