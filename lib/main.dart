import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'themes.dart';
import 'utils/domain_layer/reminder_data_state.dart';
import 'utils/ui_layer/ui_reminder_group_manager.dart';
import 'utils/domain_layer/reminder_list_order_manager.dart';
import '../utils/navigation_manager.dart';
import 'package:intervallic_app/utils/data_layer/settings_manager.dart';

import 'utils/setup_debug_app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDebugDatabase(); // Deletes existing database on the phone and rebuilds it. Populates with test data
  await clearNotifications(); // Clears all existing local notifications
  await clearPreferences(); // Clears all existing shared preferences

  String? themeKey = await SettingsManager().settings.getAppTheme(); // Defaults to 'intervallic'. See data_layer/settings_manager.dart.

  return runApp(
    MultiProvider(
      providers: [
        // Change Notifier Provider for Reminder Data state management
        ChangeNotifierProvider(create: (context) => ReminderDataState()),
        // Change Notificer Provider for UI group management
        ChangeNotifierProvider(create: (context) => UIReminderGroupManager()),
        // Change Notificer Provider for group reordering
        ChangeNotifierProvider(create: (context) => ReminderListOrderManager()),
        // Change Notificer Provider for navigation
        ChangeNotifierProvider(create: (context) => NavigationManager()),
        // Change Notifier Provider for theme data
        ChangeNotifierProvider(create: (context) => ThemeManager(themeKey))
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
      theme: Provider.of<ThemeManager>(context, listen: false).appTheme.themeData,
      home: Consumer<NavigationManager>(
        builder: (context, manager, _) {
          final List<Widget> stack = manager.pageStack;
          
          return Navigator(
            pages: [
              for(int i = 0; i < stack.length; i++)
                MaterialPage(child: stack[i])
            ],
            onPopPage: (route, result) {
              return route.didPop(result);
            },
          ); // Abstracting the Scaffold from the MaterialApp to ensure MaterialLocalizations works for showDialog
        },
      )
    );
  }
}

