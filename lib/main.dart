import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'utils/domain.dart';
import 'utils/DBHelper.dart';
import 'ui/ReminderList.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBHelper.db.setupDebugDatabase(); // Deletes existing database on the phone and rebuilds it. Populates with test data

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Intervallic"),
        ),
        body: ReminderList(), // The to-do list
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
    );
  }
}
