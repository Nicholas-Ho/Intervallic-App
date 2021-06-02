import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:intervallic_app/utils/domain.dart';
import 'package:intervallic_app/models/models.dart';

import 'package:provider/provider.dart';

// The to-do list
class ReminderList extends StatelessWidget {
  @override
  Widget build(context) {
    return Consumer<ReminderDataState>(// Consumer for Reminder Data
        builder: (context, reminderDataState, child) {
          return FutureBuilder(
              // Future Builder for queried Reminder Data
              future: reminderDataState.reminderData,
              builder: (context,
                  AsyncSnapshot<Map<ReminderGroup, List<Reminder>>> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: generateContainers(snapshot.data),
                    padding: const EdgeInsets.all(10),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });
    });
  }

  // Generates List of Reminder Group containers (for each Reminder Group)
  List<ReminderGroupContainer> generateContainers(Map<ReminderGroup, List<Reminder>> reminderData) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ReminderGroupTile(reminderGroup: reminderGroup),
          RemindersInGroup(reminders: reminders),
      ]),
    );
  }
}

// Tile for Reminder Group
class ReminderGroupTile extends StatelessWidget {
  final ReminderGroup reminderGroup;

  ReminderGroupTile({this.reminderGroup});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 60,
        width: 370,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 30,
                  spreadRadius: -15,
                  color: Colors.black.withOpacity(0.3))
            ]),
        child: Text(reminderGroup.name),
        alignment: Alignment.centerLeft,
      )
    );
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
        return ReminderTile(reminder: reminders[index]);
      }),
    );
  }
}

// Tile for Reminder
class ReminderTile extends StatelessWidget {
  final Reminder reminder;

  ReminderTile({this.reminder});
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 60,
        width: 350,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 30,
                  spreadRadius: -15,
                  color: Colors.black.withOpacity(0.5))
            ]),
        child: Text(reminder.name),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}