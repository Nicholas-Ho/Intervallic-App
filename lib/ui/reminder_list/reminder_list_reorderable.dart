import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/utils/domain_layer/reminder_list_order_manager.dart';
import 'package:intervallic_app/ui/reminder_list/reminder_list.dart';
import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'placeholders/loading_reorderable_placeholder.dart';
import 'placeholders/loading_reminder_list_placeholder.dart';

// Wrapped Reminder List to switch between the actual Reminder List and the Reorderable List (for reordering the Groups)
class ReminderListWrapped extends StatelessWidget {
  const ReminderListWrapped({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderListOrderManager>(
      builder: (context, reminderListOrderManager, _) {
        return reminderList(context, reminderListOrderManager);
      }
    );
  }

  Widget reminderList(BuildContext context, ReminderListOrderManager manager) {
    if(manager.isReordering == true) {
      // If the user is reordering Groups, display ReminderListReorderable
      // See ReminderList for explanation of Consumer => FutureBuilder => Child via comments
      return Consumer<ReminderDataState>(
        builder: (context, reminderDataState, child) {
          return FutureBuilder(
            future: Future.wait([
              reminderDataState.reminderData,
              manager.getUIGroupListOrder()
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data![0].isNotEmpty) {
                  return ReminderListReorderable(
                    initialData: snapshot.data![0],
                    initialOrder: snapshot.data![1]
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
    } else {
      return ReminderList();
    }
  }
}

// The Reorderable List (for reordering Reminder Groups)
class ReminderListReorderable extends StatefulWidget {
  const ReminderListReorderable({ this.initialOrder = const [], this.initialData = const {}, Key? key }) : super(key: key);

  final List<int> initialOrder;
  final Map<ReminderGroup, List<Reminder>> initialData;

  @override
  _ReminderListReorderableState createState() => _ReminderListReorderableState();
}

class _ReminderListReorderableState extends State<ReminderListReorderable> {
  List<ReminderGroup> reminderGroupList = [];

  @override
  void initState() {
    super.initState();
    List<ReminderGroup> initialData = widget.initialData.keys.toList();

    // Populate list in the order provided by the app Settings (from shared preferences)
    for(int id in widget.initialOrder) {
      try {
        final reminderGroup = initialData.firstWhere((group) => group.id == id);
        reminderGroupList.add(reminderGroup);
        initialData.remove(reminderGroup);
      } on StateError {
        print('Reminder Group not found.');
      }
    }

    // If there are any entries still not sorted, add them to the list
    reminderGroupList.addAll(initialData);

    // Update Reminder List loading placeholder
    LoadingReminderListPlaceholderState.state.updatePlaceholder(ListView(
      physics: BouncingScrollPhysics(),
      children: [
        for(int i = 0; i < reminderGroupList.length; i++)
          buildTile(context, i)
      ],
      padding: const EdgeInsets.all(10),
    ));
  }

  Widget buildTile(context, index) {
    final reminderGroup = reminderGroupList[index];

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
    // Update index
    setState(() {
      // Accounting for the in-place removing of the group
      if(newIndex > oldIndex){
        newIndex-=1;
      }
      final ReminderGroup group = reminderGroupList.removeAt(oldIndex);
      reminderGroupList.insert(newIndex, group);
    });

    final List<int> newListOrder = reminderGroupList.map((group) => group.id!).toList();
    Provider.of<ReminderListOrderManager>(context, listen: false).updateUIGroupListOrder(newListOrder);
    
    // Update Reminder List loading placeholder
    LoadingReminderListPlaceholderState.state.updatePlaceholder(ListView(
      physics: BouncingScrollPhysics(),
      children: [
        for(int i = 0; i < reminderGroupList.length; i++)
          buildTile(context, i)
      ],
      padding: const EdgeInsets.all(10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: reminderGroupList.length,
      itemBuilder: (context, index) {
        return buildTile(context, index);
      },
      padding: const EdgeInsets.all(10),
      onReorder: onReorder,
    );
  }
}

// Appbar button to begin reorderings
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
    }

    final isReordering = manager.isReordering;
    if(isReordering == false) {
      // Enable button only if reminderDataState is not empty
      return IconButton(
        icon: Icon(Icons.format_list_bulleted),
        color: enabled ? Colors.white : Theme.of(context).disabledColor,
        onPressed: enabled ? buttonOnPressed : null,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.done),
        color: Color(0xff99FF99),
        onPressed: () {
          manager.endReorder();
        },
      );
    }
  }
}