import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'tiles.dart';
import 'reminder_animated_list.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';
import 'shimmer_loading_list.dart';
import 'empty_reminder_list_placeholder.dart';

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
                  // If snapshot.hasData returns true, reminderData has been fetched
                  if (snapshot.data!.isNotEmpty) {
                    // If reminderData is not empty, display the list
                    return ListView(
                      physics: BouncingScrollPhysics(),
                      children: generateContainers(snapshot.data!),
                      padding: const EdgeInsets.all(10),
                    );
                  } else {
                    // If reminderData is empty, display the empty list placeholder
                    return EmptyReminderListPlaceholder();
                  }
                } else {
                  // If snapshot.hasData returns false, reminderData has not been fetched
                  return ShimmerLoadingList();
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