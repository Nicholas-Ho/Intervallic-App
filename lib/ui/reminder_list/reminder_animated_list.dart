import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './tiles.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';

// Contains Reminders in the Reminder Group
class ReminderAnimatedList extends StatefulWidget {
  final List<Reminder>? initialReminders;
  
  ReminderAnimatedList({this.initialReminders});

  @override
  _ReminderAnimatedListState createState() => _ReminderAnimatedListState();
}

class _ReminderAnimatedListState extends State<ReminderAnimatedList> {
  List<Reminder> _reminders = [];
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final int addAnimationDuration = 700; // In milliseconds

  @override
  void initState() {
    super.initState();
    _initReminders();
  }

  @override
  void didUpdateWidget(ReminderAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update Animated List on NotifyListeners() call
    if(widget.initialReminders!.length > _reminders.length) {
      // If Reminder is added
      int difference = widget.initialReminders!.length - _reminders.length;
      for(int i = 0; i < widget.initialReminders!.length; i++) {
        final reminder = widget.initialReminders![i];
        _reminders.firstWhere(
          (element) => element.id == reminder.id,
          orElse: () {
            // If Reminder does not exist, add it
            _addReminder(reminder);
            difference--;
            return Reminder(id: -1); // Placeholder null
          });
        if(difference == 0) { break; }
      }
    } else if(widget.initialReminders!.length < _reminders.length) {
      // If Reminder is deleted
      int difference = _reminders.length - widget.initialReminders!.length;
      for(int i = 0; i < _reminders.length; i++) {
        final reminder = _reminders[i];
        widget.initialReminders!.firstWhere(
          (element) => element.id == reminder.id,
          orElse: () {
            // If Reminder does not exist in the updated initialReminders, remove it
            _removeReminder(reminder);
            difference--;
            return Reminder(id: -1); // Placeholder null
          });
        if(difference == 0) { break; }
      }
    }
  }

  void _initReminders() {
    // Add all initial Reminders to the list (sorted by NextDate)
    for(int i = 0; i < widget.initialReminders!.length; i++) {
      Reminder reminder = widget.initialReminders![i];
      _addReminder(reminder, editState: false); // The AnimatedList automatically initialises its state to initialItemCount
    }
  }

  void _addReminder(Reminder reminder, {bool editState = true}) {
    // Add Reminder (sorted by NextDate)
    bool isInserted = false;

    void _insert(index, reminder) {
      _reminders.insert(index, reminder);
      if(editState == true) {
        listKey.currentState!.insertItem(index, duration: Duration(milliseconds: addAnimationDuration));
      }
      isInserted = true;
    }
    
    for(int j = 0; j < _reminders.length; j++) {
      final difference = reminder.nextDate!.difference(_reminders[j].nextDate!); // Negative if reminder.nextDate is before _reminders[j].nextDate
      if(difference.isNegative) { // If the reminder's nextDate is before _reminders[j]'s nextDate
        _insert(j, reminder);
        break;
      } else if (difference == Duration.zero && reminder.name!.compareTo(_reminders[j].name!) != 1) { // If they have the same nextDate, compare names
        _insert(j, reminder);
        break;
      }
    }

    if(isInserted == false) {
      if(editState == true) {
        listKey.currentState!.insertItem(_reminders.length > 0 ? _reminders.length: 0, duration: Duration(milliseconds: addAnimationDuration));
      }
      _reminders.add(reminder);
    }
  }

  void _removeReminder(Reminder reminder, {int? index, bool animate = true}) {
    if(index == null) {
      index = _reminders.indexOf(reminder);
    }

    listKey.currentState!.removeItem(index, (context, animation) => Container());
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
            _removeReminder(reminder, index: index, animate: false);
            _addReminder(updatedReminder);
          });
        },
      )
    );
  }
}