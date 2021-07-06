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
          RemindersInGroup(initialReminders: reminders),
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
class RemindersInGroup extends StatefulWidget {
  final List<Reminder> initialReminders;
  
  RemindersInGroup({this.initialReminders});

  @override
  _RemindersInGroupState createState() => _RemindersInGroupState();
}

class _RemindersInGroupState extends State<RemindersInGroup> {
  List<Reminder> _reminders = [];
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final int addAnimationDuration = 700; // In milliseconds

  @override
  void initState() {
    super.initState();
    _initReminders();
  }

  void _initReminders() {
    // Add all initial Reminders to the list (sorted by NextDate)
    for(int i = 0; i < widget.initialReminders.length; i++) {
      Reminder reminder = widget.initialReminders[i];
      _addReminder(reminder, editState: false); // The AnimatedList automatically initialises its state to initialItemCount
    }
  }

  void _addReminder(Reminder reminder, {bool editState = true}) {
    // Add Reminder (sorted by NextDate)
    bool isInserted = false;

    void _insert(index, reminder) {
      _reminders.insert(index, reminder);
      if(editState == true) {
        listKey.currentState.insertItem(index, duration: Duration(milliseconds: addAnimationDuration));
      }
      isInserted = true;
    }
    
    for(int j = 0; j < _reminders.length; j++) {
      final difference = reminder.nextDate.difference(_reminders[j].nextDate); // Negative if reminder.nextDate is before newList[j].nextDate
      if(difference.isNegative) { // If the reminder's nextDate is before newList[j]'s nextDate
        _insert(j, reminder);
        break;
      } else if (difference.inMicroseconds == 0 && reminder.name.compareTo(_reminders[j].name) != 1) { // If they have the same nextDate, compare names
        _insert(j, reminder);
        break;
      }
    }

    if(isInserted == false) {
      if(editState == true) {
        listKey.currentState.insertItem(_reminders.length > 0 ? _reminders.length: 0, duration: Duration(milliseconds: addAnimationDuration));
      }
      _reminders.add(reminder);
    }
  }

  void _removeReminder(Reminder reminder, int index) {
    listKey.currentState.removeItem(index, (context, animation) => Container());
    _reminders.remove(reminder);
  }

  @override
  Widget build(context) {
    return AnimatedList(
      key: listKey,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      initialItemCount: _reminders.length,
      itemBuilder: (context, index, animation) {
        return _buildItems(context, index, animation);
      });
  }

  _buildItems(context, index, animation) {
    final reminder = _reminders[index];
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      child: Dismissible(
        key: UniqueKey(),
        child: ReminderTile(reminder: reminder),
        onDismissed: (direction) {
          final updatedReminder = reminder.getNewNextDate();
          Provider.of<ReminderDataState>(context, listen: false).updateReminder(updatedReminder, rebuild: false);
          // Remove and add manually
          setState(() {
            _removeReminder(reminder, index);
            _addReminder(updatedReminder);
          });
        },
      )
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
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: SizedBox(
        height: 60,
        width: 370,
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