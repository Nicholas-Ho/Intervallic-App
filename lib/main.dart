import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'utils/DBHelper.dart';
import 'models/models.dart';
import 'utils/domain.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDebugDatabase(); // Deletes existing database on the phone and rebuilds it. Populates with test data

  return runApp(
    ChangeNotifierProvider( // Change Notifier Provider for Reminder Data state management
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
          title: Text("Reminder App!"),
        ),
        body: ReminderGroupList(), // The to-do list
      ),
    );
  }
}

// The to-do list
class ReminderGroupList extends StatelessWidget {
  @override
  Widget build(context) {
    return Consumer<ReminderDataState>( // Consumer for Reminder Data
        builder: (context, reminderDataState, child) {
          return FutureBuilder( // Future Builder for queried Reminder Data
              future: reminderDataState.reminderData,
              builder: (context, AsyncSnapshot<Map<ReminderGroup, List<Reminder>>> snapshot) {
                print(snapshot.data.length);
                if (snapshot.hasData) {
                  return ListView(children: generateContainers(snapshot.data));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });
    }   );
  }

  // Generates List of Reminder Group containers (for each Reminder Group)
  List<ReminderGroupContainer> generateContainers(
      Map<ReminderGroup, List<Reminder>> reminderData) {
    List<ReminderGroupContainer> containerList = [];

    for (MapEntry entry in reminderData.entries) {
      containerList.add(ReminderGroupContainer(
        reminderGroup: entry.key,
        reminders: entry.value,
      ));
    }

    return containerList;
  }
}

// Contains Reminders and the Reminder Group name
class ReminderGroupContainer extends StatelessWidget {
  final ReminderGroup reminderGroup;
  final List<Reminder> reminders;

  ReminderGroupContainer({this.reminderGroup, this.reminders});

  @override
  Widget build(context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      ListTile(title: Text(reminderGroup.name)),
      RemindersInGroup(reminders: reminders),
    ]);
  }
}

// Contains Reminders in the Reminder Group
class RemindersInGroup extends StatelessWidget {
  final List<Reminder> reminders;

  RemindersInGroup({this.reminders});

  @override
  Widget build(context) {
    return Column(
      children: new List.generate(reminders.length, (index) {
        return new ListTile(title: Text(reminders[index].name));
      }),
    );
  }
}

// Helper function for resetting the existing database and setting up the test database
Future<void> setupDebugDatabase() async {
  Future<void> addData() async {
    ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
    ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
    ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");

    await DBHelper.db.newReminderGroup(dailyReminders);
    await DBHelper.db.newReminderGroup(keepInTouch);
    await DBHelper.db.newReminderGroup(miscellaneous);

    Reminder doYoga = Reminder(
        id: 1,
        name: "Do Yoga",
        reminderGroupID: 1,
        interval: 100,
        lastDone: 100,
        description: null);

    await DBHelper.db.newReminder(doYoga);
  }

  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'reminders_database.db');
  await deleteDatabase(path);

  await addData();
}

/*
class ReminderGroupList extends StatelessWidget {
  @override
  Widget build(context) {
    return FutureBuilder<List<ReminderGroup>>(
        future: DBHelper.db.getAllReminderGroups(),
        builder: (context, AsyncSnapshot<List<ReminderGroup>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<ReminderGroup> groupList = snapshot.data;
            return ListView(
              children: new List.generate(groupList.length, (index) {
                return new ListTile(title: Text(groupList[index].name));
              }),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class ReminderList extends StatelessWidget {
  @override
  Widget build(context) {
    return FutureBuilder<List<Reminder>>(
        future: DBHelper.db.getAllReminders(),
        builder: (context, AsyncSnapshot<List<Reminder>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Reminder> reminderList = snapshot.data;
            return ListView(
              children: new List.generate(reminderList.length, (index) {
                return new ListTile(title: Text(reminderList[index].name));
              }),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}*/
