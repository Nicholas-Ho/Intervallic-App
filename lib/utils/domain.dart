import 'package:flutter/foundation.dart';

import 'package:intervallic_app/models/models.dart';
import 'DBHelper.dart';

// State of all reminders and reminder groups. Part of the domain layer using Provider.
class ReminderDataState extends ChangeNotifier {
  Map<ReminderGroup, List<Reminder>> _reminderData;
  IdManager _idManager;

  // Lazy getter for reminderData
  Future<Map<ReminderGroup, List<Reminder>>> get reminderData async {
    if (_reminderData != null) {
      return _reminderData;
    }

    _reminderData = await _getDBData();
    return _reminderData;
  }

  _getDBData() async {
    // Get all reminder groups
    final List<ReminderGroup> reminderGroups = await _getAllReminderGroups();
    var reminderData = new Map<ReminderGroup, List<Reminder>>();

    // For each reminder group, get all reminders for that group
    for (int i = 0; i < reminderGroups.length; i++) {
      final currentReminderGroup = reminderGroups[i];
      final List<Reminder> remindersInGroup =
          await _getRemindersByGroup(currentReminderGroup.id);
      reminderData[currentReminderGroup] = remindersInGroup;
    }

    _idManager = _initIDManager(); // Initialise ID Manager here

    return reminderData;
  }

  // Query all Reminder Groups
  Future<List<ReminderGroup>> _getAllReminderGroups() async {
    final List<Map<String, dynamic>> maps =
        await DBHelper.db.queryDatabase('reminder_groups');

    return List.generate(maps.length, (i) {
      return ReminderGroup.fromMap(maps[i]);
    });
  }

  // Query Reminders by Reminder Group ID
  Future<List<Reminder>> _getRemindersByGroup(int group) async {
    final List<Map<String, dynamic>> maps = await DBHelper.db
        .queryDatabase('reminders', whereColumn: 'reminder_group_id', whereArg: '$group');

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  _initIDManager() async {
    // Query all Primary Keys
    Future<Map<String, List<int>>> _getAllPrimaryKeys(List<String> tables) async {
      Map<String, List<int>> keys;
      for (int i = 0; i < tables.length; i++) {
        List<Map<String, dynamic>> pkMap = await DBHelper.db.queryDatabase(tables[i], columns: ['id']);
        keys[tables[i]] = List.generate(pkMap.length, (i) {
          return pkMap[i]['id'];
        });
      }
      return keys;
    }

    List<String> tables = ['reminders', 'reminder_groups'];
    return IdManager(await _getAllPrimaryKeys(tables));
  }

  // Adding new Reminder
  newReminder(Reminder newReminder) async {
    newReminder.id = _idManager.nextAvailableID('reminder');

    try {
      final data = await reminderData;
      final reminderGroup = data.keys.firstWhere((group) => group.id == newReminder.reminderGroupID);

      _reminderData[reminderGroup].add(newReminder);

      // Add to database
     DBHelper.db.newEntryToDB('reminders', newReminder.toMap());

     notifyListeners();
    } on StateError {
      print('Reminder group does not exist. New reminder not added.');
    }
  }

  // Adding new Reminder Group
  newReminderGroup(ReminderGroup newGroup) async {
    newGroup.id = _idManager.nextAvailableID('reminder_groups');
    final data = await reminderData;
    if ((data.keys.firstWhere((group) => group.id == newGroup.id)) == null) {
      _reminderData[newGroup] = [];

      // Add to database
      DBHelper.db.newEntryToDB('reminder_groups', newGroup.toMap());

      notifyListeners();
    } else {
      print('Reminder group ID already used. New reminder group not added.');
    }
  }

  // Updating an existing Reminder
  updateReminder(Reminder updatedReminder) async {
    try {
      final data = await reminderData;
      final reminderGroup = data.keys.firstWhere((group) => group.id == updatedReminder.reminderGroupID);
      final reminderIndex = data[reminderGroup].indexWhere((reminder) => reminder.id == updatedReminder.id);

      if (reminderIndex != -1) {
        _reminderData[reminderGroup][reminderIndex] = updatedReminder;

        // Update database
        DBHelper.db.updateEntryToDB('reminders', updatedReminder.toMap());

        notifyListeners();
      } else {
        print('Reminder does not exist. Reminder not updated.');
      }
    } on StateError {
      print('Reminder group does not exist. Reminder not updated.');
    }
  }

  // Updating an existing Reminder Group
  updateReminderGroup(ReminderGroup updatedReminderGroup) async {
    var existsFlag = false;
    final data = await reminderData;
    Map<ReminderGroup, List<Reminder>> newData = {};

    data.forEach((key, value) {
      if(key == updatedReminderGroup) {
        newData[updatedReminderGroup] = value;
        existsFlag = true;
      } else {
        newData[key] = value;
      }
    });

    if(existsFlag) {
      _reminderData = newData;

      // Update database
      DBHelper.db.updateEntryToDB('reminder_groups', updatedReminderGroup.toMap());

      notifyListeners();
    } else {
      print('Reminder Group does not exist. Reminder Group not updated.');
    }
  }

  // Deleting an existing Reminder
  deleteReminder(Reminder deletedReminder) async {
    try {
      final data = await reminderData;
      final reminderGroup = data.keys.firstWhere((group) => group.id == deletedReminder.reminderGroupID);

      final isInGroup = _reminderData[reminderGroup].remove(deletedReminder);

      if(isInGroup) {
        // Delete from database
        DBHelper.db.deleteFromDB('reminders', deletedReminder.toMap());

        notifyListeners();
      } else {
        print('Reminder does not exist. Reminder not deleted.');
      }
    } on StateError {
      print('Reminder Group does not exist. Reminder not deleted.');
    }
  }

  // Deleting an existing Reminder Group
  deleteReminderGroup(Reminder deletedReminderGroup) async {
    final isInGroup = _reminderData.remove(deletedReminderGroup);

    if(isInGroup != null) {
      // Delete from database
      DBHelper.db.deleteFromDB('reminder_groups', deletedReminderGroup.toMap());

      notifyListeners();
    } else {
      print('Reminder Group does not exist. Reminder Group not deleted.');
    }
  }
}

class IdManager {
  Map<String, List<int>> _idMaps;
  Map<String, int> _nextAvailableIDs;

  IdManager(Map<String, List<int>> idMaps) { // Pass in the raw values of the SQL query of Primary Keys in a table
    idMaps.forEach((key, value) {
      value.sort(); // sort just in case
      _idMaps[key] = value;

      // For the following sorted id list: [1, 2, 3, 6], since when the index = 3, value = 6, which is not index + 1, the next available id is 4
      // For the following sorted id list: [1, 2, 3, 4], since for all values, value = index + 1, the next available id is 5, or length + 1
      int nextAvailableID = value.length + 1;
      for (int i = 0; i < value.length; i++) {
        if(value[i] != i + 1) {
          nextAvailableID = i + 1;
          break;
        }
      }
      _nextAvailableIDs[key] = nextAvailableID;
    });
  }

  int nextAvailableID(String table) {
    int nextAvailableID = _nextAvailableIDs[table]; // current nextAvailableID
    _idMaps[table].insert(nextAvailableID - 1, nextAvailableID);

    int newAvailableID = _idMaps[table].length + 1;
    for (int i = nextAvailableID; i < _idMaps[table].length; i++) { // We only need to check from the current nextAvailableID
      if(_idMaps[table][i] != i + 1) {
        newAvailableID = i + 1;
        break;
      }
    }
    _nextAvailableIDs[table] = newAvailableID;

    return nextAvailableID;
  }

  void removeID(String table, int id) {
    if (_nextAvailableIDs[table] > id) {
      _nextAvailableIDs[table] = id;
    }

    _idMaps[table].remove(id);
  }
}