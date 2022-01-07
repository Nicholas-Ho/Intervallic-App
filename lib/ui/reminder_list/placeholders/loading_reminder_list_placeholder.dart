import 'package:flutter/material.dart';

import 'shimmer_loading_list.dart';
import 'package:intervallic_app/models/models.dart';
import '../tiles/reminder_group_tile.dart';

// Placeholder to show while the Reorderable list fetches data
class LoadingReminderListPlaceholderState {
  static final state = LoadingReminderListPlaceholderState._(); // Singleton
  LoadingReminderListPlaceholderState._();

  Widget placeholder = ShimmerLoadingList();

  void updatePlaceholder(List<ReminderGroup> reminderGroupList) {
    placeholder = ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: reminderGroupList.length,
      itemBuilder: (context, index) {
        // Copy of ReminderListReorderable state's buildTile()
        final reminderGroup = reminderGroupList[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
            child: ReminderGroupTile(reminderGroup: reminderGroup, reminders: [],)
        );
      },
      padding: const EdgeInsets.all(10),
    );
  }
}

class LoadingReminderListPlaceholder extends StatelessWidget {
  const LoadingReminderListPlaceholder({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingReminderListPlaceholderState.state.placeholder;
  }
}