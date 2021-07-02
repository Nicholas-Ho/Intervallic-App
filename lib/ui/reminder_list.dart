import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';

// The to-do list
class ReminderList extends StatelessWidget {
  @override
  Widget build(context) {
    return Consumer<ReminderDataState>( // Consumer for Reminder Data
        builder: (context, reminderDataState, child) {
          return FutureBuilder(
              // Future Builder for queried Reminder Data
              future: reminderDataState.reminderData,
              builder: (context, AsyncSnapshot<Map<ReminderGroup, List<Reminder>>> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    physics: BouncingScrollPhysics(),
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
      child: SizedBox(
        height: 60,
        width: 370,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(reminderGroup.name),
              ),
            ),),
      ),
    );
  }
}

// Contains Reminders in the Reminder Group
class RemindersInGroup extends StatelessWidget {
  final List<Reminder> reminders;

  RemindersInGroup({this.reminders});

  @override
  Widget build(context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        height: 60,
        width: 350,
        child: Card(
          color: Colors.greenAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(reminder.name),
              ),
            ),),
      ),
    );
  }
}