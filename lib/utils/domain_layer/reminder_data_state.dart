import 'package:flutter/foundation.dart';

import 'package:intervallic_app/models/models.dart';
import '../data_layer/db_helper.dart';
import 'id_manager.dart';
import 'local_notification_manager.dart';

// State of all reminders and reminder groups. Part of the domain layer using Provider.
class ReminderDataState extends ChangeNotifier {
  Map<ReminderGroup, List<Reminder>>? _reminderData;
  late IdManager _idManager;
  late LocalNotificationManager _localNotificationManager;

  DBHelper dataLayer = DBHelper();

  // Lazy getter for reminderData
  Future<Map<ReminderGroup, List<Reminder>>> get reminderData async {
    if (_reminderData != null) {
      return _reminderData!;
    }

    _reminderData = await _getDBData();
    return _reminderData!;
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

    _idManager = await _initIDManager(); // Initialise ID Manager here
    _localNotificationManager = await _initLocalNotificationManager(reminderData); // Initialise Local Notification Manager here

    return reminderData;
  }

  // Query all Reminder Groups
  Future<List<ReminderGroup>> _getAllReminderGroups() async {
    final List<Map<String, dynamic>> maps =
        await dataLayer.queryDatabase('reminder_groups');

    return List.generate(maps.length, (i) {
      return ReminderGroup.fromMap(maps[i]);
    });
  }

  // Query Reminders by Reminder Group ID
  Future<List<Reminder>> _getRemindersByGroup(int? group) async {
    final List<Map<String, dynamic>> maps = await dataLayer
        .queryDatabase('reminders', whereColumn: 'reminder_group_id', whereArg: '$group');

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  _initIDManager() async {
    // Query all Primary Keys
    Future<Map<String, List<int?>>> _getAllPrimaryKeys(List<String> tables) async {
      Map<String, List<int?>> keys = {};
      for (int i = 0; i < tables.length; i++) {
        List<Map<String, dynamic>> pkMap = await dataLayer.queryDatabase(tables[i], columns: ['id']);
        keys[tables[i]] = List.generate(pkMap.length, (i) {
          return pkMap[i]['id'];
        });
      }
      return keys;
    }

    List<String> tables = ['reminders', 'reminder_groups'];
    return IdManager(await _getAllPrimaryKeys(tables));
  }

  _initLocalNotificationManager(Map<ReminderGroup, List<Reminder>> data) async {
    final localNotificationManager = LocalNotificationManager();
    localNotificationManager.init(data);
    
    return localNotificationManager;
  }

  // Adding new Reminder
  newReminder(Reminder newReminder) async {
    try {
      final data = await reminderData;
      final reminderGroup = data.keys.firstWhere((group) => group.id == newReminder.reminderGroupID);

      // Only call nextAvailableID if no error is thrown
      newReminder = newReminder.setID(_idManager.nextAvailableID('reminders'));
      _reminderData![reminderGroup]!.add(newReminder);
      print(await reminderData);

      // Create notification
      _localNotificationManager.addNotifications(newReminder);

      // Add to database
     dataLayer.newEntryToDB('reminders', newReminder.toMap());

     notifyListeners();
    } on StateError {
      print('Reminder group does not exist. New reminder not added.');
    }
  }

  // Adding new Reminder Group
  newReminderGroup(ReminderGroup newGroup) async {
    final data = await reminderData;
    final isTaken = data.keys.firstWhere((group) => group.name == newGroup.name, orElse: () {
      // Only call nextAvailableID if no error is thrown
      newGroup = newGroup.setID(_idManager.nextAvailableID('reminder_groups'));
      _reminderData![newGroup] = [];

      // Add to database
      dataLayer.newEntryToDB('reminder_groups', newGroup.toMap());

      notifyListeners();

      return ReminderGroup(id: -1); // Placeholder null
    });

    if (isTaken != ReminderGroup(id: -1)) {
      print('Identical Reminder Group exists!');
    }
  }

  // Updating an existing Reminder
  updateReminder(Reminder updatedReminder, {bool rebuild = true}) async {
    try {
      final data = await reminderData;
      final reminderGroup = data.keys.firstWhere((group) => group.id == updatedReminder.reminderGroupID);
      final reminderIndex = data[reminderGroup]!.indexWhere((reminder) => reminder.id == updatedReminder.id);

      if (reminderIndex != -1) {
        _reminderData![reminderGroup]![reminderIndex] = updatedReminder;

        // Update notification
        _localNotificationManager.updateNotifications(updatedReminder);

        // Update database
        dataLayer.updateEntryToDB('reminders', updatedReminder.toMap());

        if(rebuild) { notifyListeners(); }
      } else {
        // Taking into account if a Reminder's Reminder Group was changed.
        bool isFound = false;
        
        for(ReminderGroup group in data.keys) {
          for(Reminder reminder in data[group]!) {
            if(reminder.id == updatedReminder.id) {
              if(reminder.reminderGroupID != updatedReminder.reminderGroupID) {
                data[group]!.remove(reminder);
                data[reminderGroup]!.add(updatedReminder);

                // Update database
                dataLayer.updateEntryToDB('reminders', updatedReminder.toMap());

                if(rebuild) { notifyListeners(); }
              }
              
              isFound = true;
              break;
            }
          }

          if(isFound == true) { break; }
        }

        if(isFound == true) {
          print('Reminder does not exist. Reminder not updated.');
        }
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
      if(key.id == updatedReminderGroup.id) {
        newData[updatedReminderGroup] = value;
        existsFlag = true;
      } else {
        newData[key] = value;
      }
    });

    if(existsFlag) {
      _reminderData = newData;

      // Update database
      dataLayer.updateEntryToDB('reminder_groups', updatedReminderGroup.toMap());

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

      final isInGroup = _reminderData![reminderGroup]!.remove(deletedReminder);

      if(isInGroup) {
        _idManager.removeID('reminders', deletedReminder.id!); // Only remove ID if Reminder was removed

        // Create notification
        _localNotificationManager.cancelNotifications(deletedReminder);

        // Delete from database
        dataLayer.deleteFromDB('reminders', deletedReminder.toMap());

        notifyListeners();
      } else {
        print('Reminder does not exist. Reminder not deleted.');
      }
    } on StateError {
      print('Reminder Group does not exist. Reminder not deleted.');
    }
  }

  // Deleting an existing Reminder Group
  deleteReminderGroup(ReminderGroup deletedReminderGroup) async {
    _reminderData ?? await reminderData; // Ensures that _getDBData has been called
    final isInGroup = _reminderData!.remove(deletedReminderGroup);

    if(isInGroup != null) {
      _idManager.removeID('reminder_groups', deletedReminderGroup.id!);

      // Delete from database
      dataLayer.deleteFromDB('reminder_groups', deletedReminderGroup.toMap());

      notifyListeners();
    } else {
      print('Reminder Group does not exist. Reminder Group not deleted.');
    }
  }
}