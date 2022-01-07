import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/utils/domain_layer/reminder_list_order_manager.dart';
import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'placeholders/loading_reorderable_placeholder.dart';
import 'placeholders/loading_reminder_list_placeholder.dart';
import 'package:intervallic_app/utils/navigation_manager.dart';

// The Reorderable List (for reordering Reminder Groups)
class ReminderListReorderable extends StatefulWidget {
  const ReminderListReorderable({ Key? key }) : super(key: key);


  @override
  _ReminderListReorderableState createState() => _ReminderListReorderableState();
}

class _ReminderListReorderableState extends State<ReminderListReorderable> {
  List<ReminderGroup>? reminderGroupList;

  void init(Map<ReminderGroup, List<Reminder>> initialData, initialOrder) {
    List<ReminderGroup> data = initialData.keys.toList();
    reminderGroupList = [];

    // Populate list in the order provided by the app Settings (from shared preferences)
    for(int id in initialOrder) {
      try {
        final reminderGroup = data.firstWhere((group) => group.id == id);
        reminderGroupList!.add(reminderGroup);
        data.remove(reminderGroup);
      } on StateError {
        print('Reminder Group not found.');
      }
    }

    // If there are any entries still not sorted, add them to the list
    reminderGroupList!.addAll(data);

    // Update Reminder List loading placeholder
    LoadingReminderListPlaceholderState.state.updatePlaceholder(reminderGroupList!);
  }

  Widget buildTile(context, index) {
    final reminderGroup = reminderGroupList![index];

    return Padding(
      key: ValueKey(reminderGroup),
      padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 60,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(reminderGroup.name!, style: TextStyle(fontSize: 20)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.reorder),
                  )
                ]
              ),
            ),
          ),
        ),
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    // Accounting for the in-place removing of the group
    if(newIndex > oldIndex){
      newIndex-=1;
    }
    
    // Update index
    setState(() {
      final ReminderGroup group = reminderGroupList!.removeAt(oldIndex);
      reminderGroupList!.insert(newIndex, group);
    });

    final List<int> newListOrder = reminderGroupList!.map((group) => group.id!).toList();
    Provider.of<ReminderListOrderManager>(context, listen: false).updateUIGroupListOrder(newListOrder);
    
    // Update Reminder List loading placeholder
    LoadingReminderListPlaceholderState.state.updatePlaceholder(reminderGroupList!);
  }

  @override
  Widget build(BuildContext context) {
    // See ReminderList for explanation of Consumer => FutureBuilder => Child via comments
    return Consumer2<ReminderDataState, ReminderListOrderManager>(
        builder: (context, reminderDataState, reminderListOrderManager, child) {
          return FutureBuilder(
            future: Future.wait([
              reminderDataState.reminderData,
              reminderListOrderManager.getUIGroupListOrder()
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data![0].isNotEmpty) {
                  reminderGroupList ?? init(snapshot.data![0], snapshot.data![1]); // init only once

                  return ReorderableListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: reminderGroupList!.length,
                    itemBuilder: (context, index) {
                      return buildTile(context, index);
                    },
                    padding: const EdgeInsets.all(10),
                    onReorder: onReorder,
                  );
                } else {
                  // Reorder button should be disabled if reminderData is empty.
                  return Container();
                }
              } else {
                // If snapshot.hasData returns false, reminderData has not been fetched
                return LoadingReorderablePlaceholder();
              }
            }
          );
        }
      );
  }
}

// Appbar button to begin reordering (renders in IntervallicPage)
class ReminderListReorderButton extends StatelessWidget {
  ReminderListReorderButton({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Consumer2<ReminderDataState, ReminderListOrderManager>(
        builder: (context, reminderDataState, reminderListOrderManager, _) {
          return FutureBuilder(
            // Future Builder for queried Reminder Data
            future: reminderDataState.reminderData,
            builder: (context, AsyncSnapshot<Map<ReminderGroup?, List<Reminder>>?> snapshot) {
              // If Reminder Data is empty, disable the reorder button
              if (snapshot.hasData) {
                if(snapshot.data!.isNotEmpty) {
                  return actionButton(context, reminderListOrderManager, true, printThis: snapshot.data!);
                } else {
                  return actionButton(context, reminderListOrderManager, false);
                }
              } else {
                return actionButton(context, reminderListOrderManager, false);
              }
            }
          );
        }
      );
  }

  Widget actionButton(BuildContext context, ReminderListOrderManager manager, bool enabled, {printThis}) {
    void buttonOnPressed() {
      manager.beginReorder();
      NavigationManager().changePage(AppPage.reorderPage);
    }

    // Enable button only if reminderDataState is not empty
    return IconButton(
      icon: Icon(Icons.format_list_bulleted),
      color: enabled ? Colors.white : Theme.of(context).disabledColor,
      onPressed: enabled ? buttonOnPressed : null,
    );
  }
}

// Appbar button to end reordering (renders in ReorderPage)
class EndReorderButton extends StatelessWidget {
  const EndReorderButton({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.done),
      color: Color(0xff99FF99),
      onPressed: () {
        Provider.of<ReminderListOrderManager>(context, listen: false).endReorder();
        NavigationManager().changePage(AppPage.intervallicPage);
      },
    );
  }
}

// Appbar button to end reordering (renders in ReorderPage)
class CancelReorderButton extends StatelessWidget {
  const CancelReorderButton({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.close),
      color: Color(0xffec1c24),
      onPressed: () {
        Provider.of<ReminderListOrderManager>(context, listen: false).cancelReorder();
        NavigationManager().changePage(AppPage.intervallicPage);
      },
    );
  }
}