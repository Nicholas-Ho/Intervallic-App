import 'package:equatable/equatable.dart'; // Allows for identical object comparisons for testing purposes

// Objects for data

class ReminderGroup extends Equatable {
  final int id;
  final String name;

  ReminderGroup({this.id, this.name}); // Constructor

  @override
  List<Object> get props => [id, name]; // Required for Equatable

  ReminderGroup setID(int id) { // Necessary as Equatable is immutable
    var map = this.toMap();
    map['id'] = id;
    return ReminderGroup.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  static ReminderGroup fromMap(Map<String, dynamic> map) {
    return ReminderGroup(
        id: map['id'],
        name: map['name'],
      );
  }
}

class Reminder extends Equatable {
  final int id;
  final String name;
  final int reminderGroupID;
  final int interval; // Duration.inMilliseconds
  final int lastDone; // DateTime.millisecondsSinceEpoch
  final String description;

  Reminder({this.id, this.name, this.reminderGroupID, this.interval, this.lastDone, this.description});

  @override
  List<Object> get props => [id, name, reminderGroupID, interval, lastDone, description]; // Required for Equatable

  Reminder setID(int id) { // Necessary as Equatable is immutable
    var map = this.toMap();
    map['id'] = id;
    return Reminder.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reminder_group_id': reminderGroupID,
      'interval': interval,
      'last_done': lastDone,
      'description': description,
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
        id: map['id'],
        name: map['name'],
        reminderGroupID: map['reminder_group_id'],
        interval: map['interval'],
        lastDone: map['last_done'],
        description: map['description'],
      );
  }
}