import 'package:flutter/foundation.dart';

import 'package:intervallic_app/models/models.dart';
import 'DBHelper.dart';

// State of all reminders and reminder groups. Part of the domain layer using Provider.
class ReminderDataState extends ChangeNotifier {
  Map<ReminderGroup, List<Reminder>> _reminderData;

  // Lazy getter for reminderData
  Future<Map<ReminderGroup, List<Reminder>>> get reminderData async {
    if (_reminderData != null) {
      return _reminderData;
    }

    _reminderData = await _getDBData();
    return _reminderData;
  }

  Future<Map<ReminderGroup, List<Reminder>>> _getDBData() async {
    // Get all reminder groups
    final List<ReminderGroup> reminderGroups = await DBHelper.db.getAllReminderGroups();
    var reminderData = new Map<ReminderGroup, List<Reminder>>();

    // For each reminder group, get all reminders for that group
    for (int i = 0; i < reminderGroups.length; i++) {
      final currentReminderGroup = reminderGroups[i];
      final List<Reminder> remindersInGroup =
          await DBHelper.db.getRemindersByGroup(currentReminderGroup.id);
      reminderData[currentReminderGroup] = remindersInGroup;
    }

    // Returns a Map with the ReminderGroup object as the key and a List of corresponding reminders as the entry
    return reminderData;
  }
}
