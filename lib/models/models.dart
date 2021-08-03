import 'package:equatable/equatable.dart';// Allows for identical object comparisons for testing purposes

enum IntervalType { // Interval Type for Reminders
  days, weeks, months, years
}

extension StringMethods on IntervalType {
  String toSimpleString() {
    return this.toString().split('.').last;
  }

  String capitalizedSimpleString() {
    String simpleString = this.toSimpleString();
    return "${simpleString[0].toUpperCase()}${simpleString.substring(1)}";
  }
}

IntervalType intervalTypeFromString(String string) {
  switch(string) {
    case 'days': { return IntervalType.days; }

    case 'weeks': { return IntervalType.weeks; }

    case 'months': { return IntervalType.months; }

    case 'years': { return IntervalType.years; }

    default: {
      print('Interval type not valid');
      return IntervalType.days;
    }
  }
}

// Objects for data

class ReminderGroup extends Equatable {
  final int? id;
  final String? name;
  final String? description;

  ReminderGroup({this.id, this.name, this.description}); // Constructor

  @override
  List<Object?> get props => [id, name]; // Required for Equatable

  ReminderGroup setID(int id) { // Necessary as Equatable is immutable
    var map = this.toMap();
    map['id'] = id;
    return ReminderGroup.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description
    };
  }

  static ReminderGroup fromMap(Map<String, dynamic> map) {
    return ReminderGroup(
        id: map['id'],
        name: map['name'],
        description: map['description']
      );
  }
}

class Reminder extends Equatable {
  final int? id;
  final String? name;
  final int? reminderGroupID;
  final int? intervalValue;
  final IntervalType? intervalType; // [Days, Weeks, Months, Years]
  final DateTime? nextDate; // DateTime.millisecondsSinceEpoch
  final String? description;

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
  List<Object?> get props => [id, name, reminderGroupID, intervalValue, intervalType, nextDate, description]; // Required for Equatable

  bool get isOverdue {
    final dateTimeDifference = this.nextDate!.difference(DateTime.now()); // Negative if overdue
    return dateTimeDifference.isNegative;
  }

  Reminder setID(int id) { // Necessary as Equatable is immutable
    var map = this.toMap();
    map['id'] = id;
    return Reminder.fromMap(map);
  }

  Reminder getNewNextDate() {
    final DateTime dateTime = this.nextDate ?? DateTime.now();

    // Calculate new Next Date
    // Set to 8am on Next Date
    late DateTime newDate;
    switch(this.intervalType) {
      case IntervalType.days: { newDate = DateTime(dateTime.year, dateTime.month, dateTime.day + this.intervalValue!, 8); }
      break;

      case IntervalType.weeks: { newDate = DateTime(dateTime.year, dateTime.month, dateTime.day + (this.intervalValue! * 7), 8); }
      break;

      case IntervalType.months: { newDate = DateTime(dateTime.year, dateTime.month + this.intervalValue!, dateTime.day, 8); }
      break;

      case IntervalType.years: { newDate = DateTime(dateTime.year + this.intervalValue!, dateTime.month, dateTime.day, 8); }
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
      'interval_type': intervalType!.toSimpleString(),
      'next_date': nextDate!.millisecondsSinceEpoch,
      'description': description,
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    // Converting a String into an IntervalType
    IntervalType mapIntervalType = intervalTypeFromString(map['interval_type']);

    return Reminder(
        id: map['id'],
        name: map['name'],
        reminderGroupID: map['reminder_group_id'],
        intervalValue: map['interval_value'],
        intervalType: mapIntervalType,
        nextDate: DateTime.fromMillisecondsSinceEpoch(map['next_date']),
        description: map['description'],
      );
  }
}