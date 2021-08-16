import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'tiles/reminder_tile.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/ui_layer/ui_reminder_group_manager.dart';

// Contains Reminders in the Reminder Group
class ReminderAnimatedList extends StatefulWidget {
  final List<Reminder>? initialReminders;
  final ReminderGroup? reminderGroup;
  final UIReminderGroupManager? uiGroupManager;
  
  ReminderAnimatedList({this.initialReminders, this.reminderGroup, this.uiGroupManager});

  @override
  _ReminderAnimatedListState createState() => _ReminderAnimatedListState();
}

class _ReminderAnimatedListState extends State<ReminderAnimatedList> {
  List<Reminder> _reminders = [];
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final int addAnimationDuration = 700; // In milliseconds
  final int removeAnimationDuration = 500; // In milliseconds
  final int openAnimationDuration = 300; // In milliseconds

  bool isOpen = false; // Whether the List is displaying anything (kind of like a folder)

  @override
  void initState() {
    super.initState();
    _initReminders();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async { _checkOpen(); }) ;
  }

  @override
  void didUpdateWidget(ReminderAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Checking if this list is currently open
    _checkOpen();

    // Update Animated List on NotifyListeners() call
    if(isOpen == true) {
      // If the List is already open, simply update it
      _updateList();
    } else {
      // If the List is not open, wait for it to open on the next frame
      // isOpen only get updated after the current frame
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) { _updateList(); });
    }
  }

  void _initReminders() {
    // Add all initial Reminders to the list (sorted by NextDate)
    for(int i = 0; i < widget.initialReminders!.length; i++) {
      Reminder reminder = widget.initialReminders![i];
      _addReminder(reminder, editState: false); // The AnimatedList automatically initialises its state to initialItemCount
    }
  }

  void _checkOpen() {
    final UIReminderGroupManager manager = widget.uiGroupManager!;
    final bool shouldBeOpen = manager.checkOpenGroup(widget.reminderGroup!);

    // Open or close list
    if(isOpen == false && shouldBeOpen == true) {
      _openList();
    } else if(isOpen == true && shouldBeOpen == false) {
      _closeList();
    }
  }

  void _updateList() {
    // initialReminders is the NEW, updated list (contrary to its name)
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
    } else {
      // If there is no change in List length, check if Reminder is updated
      for(int i = 0; i < _reminders.length; i++) {
        final reminder = _reminders[i];
        final initialReminder = widget.initialReminders!.firstWhere(
          (element) => element.id == reminder.id,
          orElse: () {
            print('Reminder does not exist.');
            return Reminder(id: -1); // Placeholder null
          });
        if(reminder != initialReminder) {
          // If Reminder is updated
          _removeReminder(reminder, animate: false);
          _addReminder(initialReminder);
        }
      }
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

    if(animate == true) {
      listKey.currentState!.removeItem(index, (context, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: ReminderTile(reminder: reminder),
      ), duration: Duration(milliseconds: removeAnimationDuration));
    } else {
      listKey.currentState!.removeItem(index, (context, animation) => Container());
    }
    _reminders.remove(reminder);
  }

  // Opens the Reminder Animated List like a folder
  void _openList() {
    if(isOpen == false) { // Only open the folder if it is closed
      for(int i = 0; i < _reminders.length; i++) {
        listKey.currentState!.insertItem(i, duration: Duration(milliseconds: openAnimationDuration));
      }
      // After the List has been built in the next frame (and all the items are added), set isOpen to true
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) { isOpen = true; });
    }
  }

  // Closes the Reminder Animated List like a folder
  void _closeList() {
    if(isOpen == true) { // Only close the folder if it is open
      for(int i = 0; i < _reminders.length; i++) {
        // _openListBuildItems animation is also used for closing
        // Index of 0 is used as the in-place removal will remove the whole list
        listKey.currentState!.removeItem(0, (context, animation) => _openListBuildItems(context, i, animation),
            duration: Duration(milliseconds: openAnimationDuration));
      }
      // After the List has been built in the next frame (and all the items are removed), set isOpen to false
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) { isOpen = false; });
    }
  }

  @override
  Widget build(context) {
    return AnimatedList(
      key: listKey,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      initialItemCount: 0,
      itemBuilder: (context, index, animation) {
        if(isOpen == true) {
          return _buildItems(context, index, animation);
        } else {
          return _openListBuildItems(context, index, animation);
        }
      });
  }

  _buildItems(context, index, animation) {
    final reminder = _reminders[index];
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      child: Dismissible(
        key: UniqueKey(),
        child: ReminderTile(reminder: reminder),
        onDismissed: (direction) async {
          final updatedReminder = await reminder.getNewNextDate();
          Provider.of<ReminderDataState>(context, listen: false).updateReminder(updatedReminder);
          // Remove and add manually
          setState(() {
            _removeReminder(reminder, index: index, animate: false);
            _addReminder(updatedReminder);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Completed! Reseting due date.')));
        },
      )
    );
  }

  // Animation for opening the List
  _openListBuildItems(context, index, animation) {
    Widget dismissible(Reminder reminder) {
      return Dismissible(
        key: UniqueKey(),
        child: ReminderTile(reminder: reminder),
        onDismissed: (direction) async {
          final updatedReminder = await reminder.getNewNextDate();
          Provider.of<ReminderDataState>(context, listen: false).updateReminder(updatedReminder);
          // Remove and add manually
          setState(() {
            _removeReminder(reminder, index: index, animate: false);
            _addReminder(updatedReminder);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Completed! Reseting due date.')));
        },
      );
    }
    final reminder = _reminders[index];

    final curve = Curves.easeOutBack;
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset(0, 0),
      ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,)),
      child:  SizeTransition(
        sizeFactor: CurvedAnimation(parent: animation, curve: curve),
        child: dismissible(reminder)
      )
    );
  }
}