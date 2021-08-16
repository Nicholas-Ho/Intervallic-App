import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'tiles/reminder_group_tile.dart';
import 'reminder_animated_list.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';
import 'placeholders/shimmer_loading_list.dart';
import 'placeholders/empty_reminder_list_placeholder.dart';
import 'package:intervallic_app/utils/ui_layer/ui_reminder_group_manager.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_list_order_manager.dart';
import 'placeholders/loading_reorderable_placeholder.dart';
import 'placeholders/loading_reminder_list_placeholder.dart';

// The to-do list
class ReminderList extends StatelessWidget {
  @override
  Widget build(context) {
    return Consumer2<ReminderDataState, ReminderListOrderManager>( // Consumer for Reminder Data
        builder: (context, reminderDataState, reminderListOrderManager, child) {
          return FutureBuilder(
              // Future Builder for queried Reminder Data and UI Group List Order
              future: Future.wait([
                reminderDataState.reminderData,
                reminderListOrderManager.getUIGroupListOrder()
              ]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                // snapshot.data[0] is reminderData
                // snapshot.data[1] is the UI Group List Order
                // Both Futures will be completed together. When one is finished, it will wait for the other.

                if (snapshot.hasData) {
                  // If snapshot.hasData returns true, reminderData (and the UI List Order) has been fetched
                  if (snapshot.data![0].isNotEmpty) {
                    // If reminderData is not empty, display the list
                    return ListView(
                      physics: BouncingScrollPhysics(),
                      children: generateContainers(snapshot.data![0], snapshot.data![1]),
                      padding: const EdgeInsets.all(10),
                    );
                  } else {
                    // If reminderData is empty, display the empty list placeholder
                    return EmptyReminderListPlaceholder();
                  }
                } else {
                  // If snapshot.hasData returns false, reminderData has not been fetched
                  return LoadingReminderListPlaceholder();
                }
              });
    });
  }

  // Generates List of Reminder Group containers (for each Reminder Group)
  List<ReminderGroupContainer> generateContainers(Map<ReminderGroup?, List<Reminder>> reminderData, List<int> listOrder) {
    List<ReminderGroupContainer> containerList = [];
    List<ReminderGroup> doneList = [];

    // Generate Containers in the order provided by the app Settings (from shared preferences)
    for(int id in listOrder) {
      try {
        final reminderGroup = reminderData.keys.firstWhere((group) => group!.id == id);
        containerList.add(ReminderGroupContainer(
          reminderGroup: reminderGroup,
          reminders: reminderData[reminderGroup],
        ));

        // For some reason, reminderData.remove(group) removes the Group from the Reminder Data State
        // doneList is a workaround
        doneList.add(reminderGroup!);
      } on StateError {
        print('Reminder Group not found.');
      }
    }

    // If there are any entries still not sorted, generate Containers
    for (MapEntry entry in reminderData.entries) {
      doneList.firstWhere((doneGroup) => doneGroup.id == entry.key.id, orElse: () {
        containerList.add(ReminderGroupContainer(
          reminderGroup: entry.key,
          reminders: entry.value,
        ));
        return ReminderGroup(id: -1);
      });
    }

    // Update the LoadingReorderablePlaceholder state
    LoadingReorderablePlaceholderState.state.updatePlaceholder(ListView(
      physics: BouncingScrollPhysics(),
      children: containerList,
      padding: const EdgeInsets.all(10),
    ));

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
      child: Consumer<UIReminderGroupManager>( // Consumer for UI group management
        builder: (context, manager, widget) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ReminderGroupTile(
                reminderGroup: reminderGroup,
                reminders: reminders,
              ),
              ReminderAnimatedList(
                reminderGroup: reminderGroup,
                initialReminders: reminders,
                uiGroupManager: manager,
              )
            ]
          );
        }
      )
    );
  }
}