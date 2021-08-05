import 'package:flutter/material.dart';

import 'package:intervallic_app/models/models.dart';

// Manages which Reminder Group is open in the UI (opening and closing like dropdown folders)
// Only one Reminder Group is open at a time. When another opens, the one that is currently open will close
class UIReminderGroupManager extends ChangeNotifier {
  int? _openReminderGroupID; // ID of the Reminder Group that is currently open

  void openGroup(ReminderGroup group) {
    _openReminderGroupID = group.id;
    notifyListeners();
  }

  void openGroupByID(int id) {
    _openReminderGroupID = id;
    notifyListeners();
  }

  void closeAll() {
    _openReminderGroupID = null;
    notifyListeners();
  }

  // Returns true if the Reminder Group's ID is equal to the ID of the current open Group
  bool checkOpenGroup(ReminderGroup group) {
    return group.id == _openReminderGroupID;
  }
}