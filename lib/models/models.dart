// Objects for data

class ReminderGroup {
  int id;
  String name;

  ReminderGroup({this.id, this.name}); // Constructor

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

class Reminder {
  int id;
  String name;
  int reminderGroupID;
  int interval; // Duration.inSeconds
  int lastDone; // DateTime.millisecondsSinceEpoch
  String description;

  Reminder({this.id, this.name, this.reminderGroupID, this.interval, this.lastDone, this.description});

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