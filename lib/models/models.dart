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
  final int intervalValue;
  final String intervalType; // ['Days', 'Weeks', 'Months', 'Years']
  final DateTime nextDate; // DateTime.millisecondsSinceEpoch
  final String description;

  Reminder(
    {
      this.id,
      this.name,
      this.reminderGroupID,
      this.intervalValue,
      this.intervalType,
      this.nextDate,
      this.description
    }
  );

  @override
  List<Object> get props => [id, name, reminderGroupID, intervalValue, intervalType, nextDate, description]; // Required for Equatable

  Reminder setID(int id) { // Necessary as Equatable is immutable
    var map = this.toMap();
    map['id'] = id;
    return Reminder.fromMap(map);
  }

  Reminder getNewNextDate([DateTime dateTime]) {
    dateTime = dateTime ?? DateTime.now();

    // Calculate new Next Date
    // Set to 8am on Next Date
    DateTime newDate;
    switch(this.intervalType) {
      case 'Days': { newDate = DateTime(dateTime.year, dateTime.month, dateTime.day + this.intervalValue, 8); }
      break;

      case 'Weeks': { newDate = DateTime(dateTime.year, dateTime.month, dateTime.day + (this.intervalValue * 7), 8); }
      break;

      case 'Months': { newDate = DateTime(dateTime.year, dateTime.month + this.intervalValue, dateTime.day, 8); }
      break;

      case 'Years': { newDate = DateTime(dateTime.year + this.intervalValue, dateTime.month, dateTime.day, 8); }
      break;

      default: { print('Interval type not valid'); }
      break;
    }
    var map = this.toMap();
    map['next_date'] = newDate.millisecondsSinceEpoch;
    return Reminder.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reminder_group_id': reminderGroupID,
      'interval_value': intervalValue,
      'interval_type': intervalType,
      'next_date': nextDate.millisecondsSinceEpoch,
      'description': description,
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
        id: map['id'],
        name: map['name'],
        reminderGroupID: map['reminder_group_id'],
        intervalValue: map['interval_value'],
        intervalType: map['interval_type'],
        nextDate: DateTime.fromMillisecondsSinceEpoch(map['next_date']),
        description: map['description'],
      );
  }
}