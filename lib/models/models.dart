// Objects for data

class ReminderGroup {
  final int id;
  final String name;

  ReminderGroup({this.id, this.name}); // Constructor

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Reminder {
  final int id;
  final String name;
  final int reminderGroupID;
  final int interval; // Duration.inSeconds
  final int lastDone; // DateTime.millisecondsSinceEpoch
  final String description;

  Reminder({this.id, this.name, this.reminderGroupID, this.interval, this.lastDone, this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reminderGroupID': reminderGroupID,
      'interval': interval,
      'lastDone': lastDone,
      'description': description,
    };
  }
}