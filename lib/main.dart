import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'theme.dart';
import 'utils/domain_layer/reminder_data_state.dart';
import 'ui/dialogs/create_new_navigation_dialog.dart';
import 'utils/ui_layer/ui_reminder_group_manager.dart';
import 'ui/reminder_list/reminder_list_reorderable.dart';
import 'utils/domain_layer/reminder_list_order_manager.dart';

import 'utils/setup_debug_app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDebugDatabase(); // Deletes existing database on the phone and rebuilds it. Populates with test data
  await clearNotifications(); // Clears all existing local notifications
  await clearPreferences(); // Clears all existing shared preferences

  return runApp(
    MultiProvider(
      providers: [
        // Change Notifier Provider for Reminder Data state management
        ChangeNotifierProvider(create: (context) => ReminderDataState()),
        // Change Notificer Provider for UI group management
        ChangeNotifierProvider(create: (context) => UIReminderGroupManager()),
        // Change Notificer Provider for group reordering
        ChangeNotifierProvider(create: (context) => ReminderListOrderManager()),
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
    final Color backgroundColour = getBackgroundColour(context);

    return Scaffold(
      backgroundColor: backgroundColour,
      appBar: AppBar(
        backgroundColor: backgroundColour,
        elevation: 0,
        centerTitle: true,
        title: Text("Intervallic", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [ReminderListReorderButton()],
      ),
      body: ReminderListWrapped(), // Wrapped to switch between the Reminder List and Reorderable List
      floatingActionButton: floatingActionButton(context),
    );
  }

  // Floating Action Button and Background Colour abstracted to allow for isReordering
  Widget? floatingActionButton(BuildContext context) {
    if(Provider.of<ReminderListOrderManager>(context, listen: true).isReordering) {
      return null;
    } else {
      return FloatingActionButton(
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
      );
    }
  }

  Color getBackgroundColour(BuildContext context) {
    if(Provider.of<ReminderListOrderManager>(context, listen: true).isReordering) {
      return Colors.grey;
    } else {
      return Theme.of(context).primaryColor;
    }
  }
}
