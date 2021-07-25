import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './tiles.dart';
import 'reminder_animated_list.dart';
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
              builder: (context, AsyncSnapshot<Map<ReminderGroup?, List<Reminder>>?> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    physics: BouncingScrollPhysics(),
                    children: generateContainers(snapshot.data!),
                    padding: const EdgeInsets.all(10),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });
    });
  }

  // Generates List of Reminder Group containers (for each Reminder Group)
  List<ReminderGroupContainer> generateContainers(Map<ReminderGroup?, List<Reminder>> reminderData) {
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
  final ReminderGroup? reminderGroup;
  final List<Reminder>? reminders;

  ReminderGroupContainer({this.reminderGroup, this.reminders});

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ReminderGroupTile(reminderGroup: reminderGroup),
          ReminderAnimatedList(initialReminders: reminders),
      ]),
    );
  }
}