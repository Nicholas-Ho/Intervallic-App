import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/local_notifications_service.dart';

// Local Notification logic manager.
// The app will remind the user for a week for each notification (1 notification per day for 7 days).
// The app will cap at 64 notifications (in line with iOS' maximum of 64 local notifications).
// If the user doesn't open the app after 63 notifications, the last notification will say "These reminders don't seem to be working".
// When the app opens, the notifications will be recalculated.

// Because each Reminder will need 7 notifications, the notification IDs will be calculated as follows:
// (reminder.id * 10) + day
// eg. For the Reminder with ID: 3
// Notification IDs: 31, 32, 33, 34, 35, 36, 37 (for the 7 days - essentially ID: "3, day 7")
// For Daily Notifications, the Notification ID will simply be (reminder.id * 10)
// eg. For the Reminder with ID: 5, Notification ID: 50

class LocalNotificationManager {
  static const int daysToRemind = 7; // How many days to remind the user after a Reminder is overdue
  static const int maxNotifications = 64; // Maximum number of Notifications (iOS imposed)

  LocalNotificationService localNotificationService = LocalNotificationService();

  List<Reminder> _dailyReminders = [];
  List<Reminder> _intervallicReminders = [];

  List<PendingNotificationRequest> _dailyNotifications = [];
  List<PendingNotificationRequest> _scheduledNotifications = [];

  DateTime? endNotification; // Date of "These reminders don't seem to be working".

  Future<void> init(Map<ReminderGroup, List<Reminder>> data, {bool resolveUpdates = true}) async { // resolveUpdate is for testing
    localNotificationService.init();

    // Compare current pending notifications and reminder data
    final pendingNotifications = await localNotificationService.getPendingNotificationRequests();

    // Sort Reminders into _dailyReminders and _intervallicReminders
    data.forEach((group, reminders) {
      reminders.forEach((reminder) {
        if(reminder.intervalValue == 1 && reminder.intervalType == IntervalType.days) {
          _dailyReminders.add(reminder);
        } else {
          // Sort _intervallicReminders by nextDate (Naive implementation for a small list of Reminders)
          bool isInserted = false;

          for(int j = 0; j < _intervallicReminders.length; j++) {
            final difference = reminder.nextDate!.difference(_intervallicReminders[j].nextDate!); // Negative if reminder.nextDate is before _intervallicReminders[j].nextDate
            if(difference.isNegative) { // If the reminder's nextDate is before _intervallicReminders[j]'s nextDate
              _intervallicReminders.insert(j, reminder);
              isInserted = true;
              break;
            } else if (difference == Duration.zero && reminder.id! < _intervallicReminders[j].id!) { // If they have the same nextDate, compare IDs
              _intervallicReminders.insert(j, reminder);
              isInserted = true;
              break;
            }
          }

          if(isInserted == false) {
            _intervallicReminders.add(reminder);
          }
        }
      });
    });

    // Sort Pending Notification Requests into _dailyNotifications and _scheduledNotifications
    for(int i = 0; i < pendingNotifications.length; i++) {
      if(pendingNotifications[i].id == 0) {
        endNotification = DateTime.fromMillisecondsSinceEpoch((int.parse(pendingNotifications[i].payload!)));
      } else if(pendingNotifications[i].id % 10 == 0) {
        _dailyNotifications.add(pendingNotifications[i]);
      } else {
        _scheduledNotifications.add(pendingNotifications[i]);
      }
    }

    // Sort _scheduledNotifications by nextDate
    _scheduledNotifications = _quicksort(_scheduledNotifications);


    // Check for any discrepancies in notifications scheduled
    if(resolveUpdates) {
      // Check for Daily Reminders
      for(int i = 0; i < _dailyReminders.length; i++) {
        final reminder = _dailyReminders[i];
        try{
          final notificationID = reminder.id! * 10;
          _dailyNotifications.firstWhere((notification) => notification.id == notificationID);
        } on StateError {
          // If there are no notifications scheduled for the Daily Reminder, schedule it
          await _addDailyNotification(reminder);
        }
      }

      // Check for Scheduled Reminders
      for(int i = 0; i < _intervallicReminders.length; i++) {
        final reminder = _intervallicReminders[i];
        try{
          final lastNotificationID = reminder.id! * 10 + daysToRemind;
          _scheduledNotifications.firstWhere((notification) => notification.id == lastNotificationID);
        } on StateError {
          // If there are no notifications scheduled for the Intervallic Reminder, attempt to schedule the notifications
          // The logic to determine whether or not to actually schedule the notifications is in the Function
          await _addIntervallicNotifications(reminder, updateState: false);
        }
      }
    }

  }

  // Public-facing, general function for adding notifications
  Future<void> addNotifications(Reminder reminder) async {
    if(reminder.intervalValue == 1 && reminder.intervalType == IntervalType.days) {
      // If the interval is 1 day, use the daily notification function
      await _addDailyNotification(reminder);
    } else {
      // If the interval is more than 1 day, use the intervallic notification function
      await _addIntervallicNotifications(reminder);
    }
  }

  // Public-facing, general function for cancelling notifications
  Future<void> cancelNotifications(Reminder reminder) async {
    if(reminder.intervalValue == 1 && reminder.intervalType == IntervalType.days) {
      // If the interval is 1 day, use the daily notification function
      await _cancelDailyNotification(reminder);
    } else {
      // If the interval is more than 1 day, use the intervallic notification function
      await _cancelIntervallicNotifications(reminder);
    }
  }

  // Public-facing, general function for cancelling notifications
  Future<void> updateNotifications(Reminder reminder) async {
    String reminderType = 'intervallic';
    _intervallicReminders.firstWhere((element) => element.id == reminder.id,
        orElse: () {
          final originalReminder = _dailyReminders.firstWhere((element) => element.id == reminder.id,
              orElse: () {
                print('Reminder not found in Manager.');
                reminderType = 'null';
                return Reminder(id: -10);
              });
          if(originalReminder.id != -10) { reminderType = 'daily'; }
          return originalReminder;
        });

    if(reminderType == 'daily') {
      // If the interval is 1 day, use the daily notification function
      await _updateDailyNotification(reminder);
    } else if(reminderType == 'intervallic') {
      // If the interval is more than 1 day, use the intervallic notification function
      await _updateIntervallicNotifications(reminder);
    } else {
      print('Reminder not found. Notifications not updated.');
    }
  }

  // Add a Reminder's scheduled notifications
  Future<void> _addIntervallicNotifications(Reminder reminder, {bool updateState: true}) async {
    // Add the Reminder to the Manager's state
    if(updateState) {
      _addToIntervallicRemindersList(reminder);
    }

    final now = DateTime.now();
    DateTime lastNotificationDate = reminder.nextDate!.add(Duration(days: daysToRemind));

    List<Map<String, dynamic>> notifications = [];

    // If the last notification date is after now, add the notifications. If not, do nothing
    if(now.difference(lastNotificationDate).isNegative) {
      // Each Reminder schedules a few notifications to remind the user over a few days
      // Generate notification data
      for(int i = 0; i < daysToRemind; i++) {
        final id = reminder.id! * 10 + 1 + i;
        final notificationDate = reminder.nextDate!.add(Duration(days: i));

        // Only add the notification if the scheduled date is after now
        if(now.difference(notificationDate).isNegative) {
          notifications.add({
            'id': id,
            'title': 'Reminder',
            'body': "'${reminder.name}' is overdue!",
            'date': notificationDate,
            'payload': notificationDate.millisecondsSinceEpoch.toString(),
          });
        }
      }

      // If there is space for notifications, add them
      if(_notificationSpaceAvaialable(notifications.length)) {
        for(int i = 0; i < notifications.length; i++) {
          await localNotificationService.scheduleNotification(
            notifications[i]['id'],
            notifications[i]['title'],
            notifications[i]['body'],
            notifications[i]['date'],
            payload: notifications[i]['payload'],
          );
          _addToScheduledNotificationsList(PendingNotificationRequest(
            notifications[i]['id'],
            notifications[i]['title'],
            notifications[i]['body'],
            notifications[i]['payload'],
          ));
        }
      } else {
        // If there is no space, check to see if the last notification is earlier than the current last notification
        final currentLastDate = endNotification ??
            DateTime.fromMillisecondsSinceEpoch(int.parse(_scheduledNotifications.last.payload!));
        
        // If it is, cancel the last Reminder's notifications and add the new notifications. If not, do nothing.
        if(lastNotificationDate.difference(currentLastDate).isNegative) {
          await _cancelLastReminderNotifications(); // Loop not required as no case will need more than one deletion

          for(int i = 0; i < notifications.length; i++) {
            await localNotificationService.scheduleNotification(
              notifications[i]['id'],
              notifications[i]['title'],
              notifications[i]['body'],
              notifications[i]['date'],
              payload: notifications[i]['payload'],
            );
            _addToScheduledNotificationsList(PendingNotificationRequest(
              notifications[i]['id'],
              notifications[i]['title'],
              notifications[i]['body'],
              notifications[i]['payload'],
            ));
          }
        }

        // Since there is no space, add the end notification to signify that there are still unscheduled notifications
        await _setEndNotification();
      }
    }
  }

  // Cancel a Reminder's scheduled notifications
  Future<void> _cancelIntervallicNotifications(Reminder reminder) async {
    // Remove the Reminder from Manager state
    _intervallicReminders.remove(reminder);

    final now = DateTime.now();
    DateTime lastNotificationDate = reminder.nextDate!.add(Duration(days: daysToRemind));

    // If the last notification date is after now, cancel the notifications. If not, do nothing
    if(now.difference(lastNotificationDate).isNegative) {
      // Each Reminder schedules a few notifications to remind the user over a few days
      for(int i = 0; i < daysToRemind; i++) {
        final id = reminder.id! * 10 + 1 + i;
        final notificationDate = reminder.nextDate!.add(Duration(days: i));

        // Only cancel the notification if the scheduled date is after now
        if(now.difference(notificationDate).isNegative) {
          try {
            final notification = _scheduledNotifications.firstWhere((notif) => notif.id == id); // Check if the notification exists

            await localNotificationService.cancelNotification(id);
            _scheduledNotifications.remove(notification);
          } on StateError {
            // Might be perfectly fine, perhaps the notifications are after the end notification
            print('Notification does not exist.');
          }
        }
      }

      await _addLastReminderNotifications(); // Attempt to schedule the notificaitons of the next earliest unscheduled Reminder
    }
  }

  // Update the notifications of a Reminder that is intervallic IN THE MANAGER'S STATE
  Future<void> _updateIntervallicNotifications(Reminder reminder) async {
    final originalReminder = _intervallicReminders.firstWhere((element) => element.id == reminder.id,
    orElse: () {
          print('Reminder not found in Manager. Are you sure it is intervallic?');
          return Reminder(id: -10);
        });

    // If the original Reminder was found
    if(originalReminder.id != -10) {
      if(reminder.intervalValue == 1 && reminder.intervalType == IntervalType.days) {
        // If the intervallic Reminder is changed into a daily one
        await _cancelIntervallicNotifications(originalReminder);
        await _addDailyNotification(reminder);
      } else if(reminder.nextDate != originalReminder.nextDate) {
        // If the Reminder's nextDate was updated, re-add it to refresh the notification queue
        await _cancelIntervallicNotifications(originalReminder);
        await _addIntervallicNotifications(reminder);
      } else if(reminder.name != originalReminder.name) {
        // If the Reminder's name was updated, re-add it (but don't cancel it).
        // Due to the nature of the Local Notification Plugin, this merely updates the notifications
        // Still, the internal Manager state must be manually managed
        for(int i = 0; i < daysToRemind; i++) {
          final id = originalReminder.id! * 10 + 1 + i;
          _scheduledNotifications.removeWhere((element) => element.id == id);
        }
        _intervallicReminders.remove(originalReminder);

        await _addIntervallicNotifications(reminder);
      }
    }
  }

  // Add a daily notification
  Future<void> _addDailyNotification(Reminder reminder) async {
    _dailyReminders.add(reminder);

    final notificationID = reminder.id! * 10;

    if(!_notificationSpaceAvaialable(1)) {
      await _cancelLastReminderNotifications();
      await _setEndNotification();
    }

    await localNotificationService.scheduleRepeatingNotification(
      notificationID,
      'Reminder',
      "'${reminder.name}' is overdue!",
      reminder.nextDate!,
      mode: 'Daily',
    );

    _dailyNotifications.add(PendingNotificationRequest(
      notificationID,
      'Reminder',
      "'${reminder.name}' is overdue!",
      null
    ));
  }

  // Cancel a daily notification
  Future<void> _cancelDailyNotification(Reminder reminder) async {
    _dailyReminders.remove(reminder);
    
    final notificationID = reminder.id! * 10;
    try {
      final notification = _dailyNotifications.firstWhere((notif) => notif.id == notificationID); // Check if the notification exists

      await localNotificationService.cancelNotification(notificationID);
      _dailyNotifications.remove(notification);
    } on StateError {
      print('Notification does not exist.');
    }

    await _addLastReminderNotifications(); // Attempt to schedule the notificaitons of the next earliest unscheduled Reminder
  }

  // Update a notification that is daily IN THE MANAGER'S STATE
  Future<void> _updateDailyNotification(Reminder reminder) async {
    try {
      final originalReminder = _dailyReminders.firstWhere((element) => element.id == reminder.id);

      if(reminder.intervalValue != 1 || reminder.intervalType != IntervalType.days) {
        // If the daily Reminder is changed into an intervallic one
        await _cancelDailyNotification(originalReminder);
        await _addIntervallicNotifications(reminder);
      } else if(reminder.name != originalReminder.name) {
        // If the Reminder's name was updated, re-add it (but don't cancel it).
        // Due to the nature of the Local Notification Plugin, this merely updates the notifications
        // Still, the internal Manager state must be manually managed
        final id = originalReminder.id! * 10;
        _dailyNotifications.removeWhere((element) => element.id == id);
        _dailyReminders.remove(originalReminder);

        await _addDailyNotification(reminder);
      }
    } on StateError {
      print('Reminder not found in Manager. Are you sure it is daily?');
    }
  }

  // Set the "These reminders don't seem to be working" notification
  Future<void> _setEndNotification() async {
    if(!_notificationSpaceAvaialable(1)){
      await _cancelLastReminderNotifications();
    }

    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(_scheduledNotifications.last.payload!)).add(Duration(days: 1));

    if(endNotification != date) {
      await localNotificationService.scheduleNotification(
        0, // ID of the notification will be the same as the Reminder ID
        'Intervallic app',
        "These reminders don't seem to be working. Open the app to continue receiving notifications.",
        date,
      );
      endNotification = date;
    }
  }

  // Remove the "These reminders don't seem to be working" notification
  Future<void> _cancelEndNotification() async {
    if(endNotification != null) {
      endNotification = null;
      await localNotificationService.cancelNotification(0);
    }
  }

  // Check if there is still space for a quantity of notifications
  bool _notificationSpaceAvaialable(int quantity) {
    // Takes into account the last notification (termination of notifications)
    final int endNotif = (endNotification != null) ? 1 : 0;
    return (_scheduledNotifications.length + _dailyNotifications.length + endNotif) <= maxNotifications - quantity;
  }

  // Remove ALL notifications of the Reminder that scheduled the latest scheduled notification
  Future<void> _cancelLastReminderNotifications() async {
    if(_scheduledNotifications.isNotEmpty) {
      final int notificationID = _scheduledNotifications.last.id;
      final int reminderID = notificationID ~/ 10;

      for(int i = 0; i < daysToRemind; i++) {
        final id = reminderID * 10 + 1 + i;

        try {
          final notification = _scheduledNotifications.firstWhere((notif) => notif.id == id); // Check if the notification exists

          localNotificationService.cancelNotification(id);
          _scheduledNotifications.remove(notification);
        } on StateError {
          // If the notification does not exist, do nothing
        }
      }
    }
  }

  // Schedule notifications of the Reminder that is after the Reminder with the latest scheduled notification
  Future<void> _addLastReminderNotifications() async {
    int lastIndex = 0;

    if(_scheduledNotifications.isNotEmpty) {
      final int notificationID = _scheduledNotifications.last.id;
      final int reminderID = notificationID ~/ 10;

      // Find the index of the Reminder scheduling the last notification, or else let lastIndex = 0
      lastIndex = _intervallicReminders.indexWhere((element) => element.id == reminderID);
      if(lastIndex == -1) { lastIndex = 0; }
    }

    // Find the next Reminder that hasn't scheduled notifications
    for(int i = lastIndex; i < _intervallicReminders.length; i++) {
      final reminder = _intervallicReminders[i];
      final lastNotificationID = (reminder.id! * 10) + daysToRemind;

      // If the Reminder is the last, all Reminders have scheduled their notifications. Cancel the end notification.
      // If the last Reminder fails to schedule its notifications due to lack of space, addIntervallicNotification will reschedule the end notification
      if(i == (_intervallicReminders.length - 1)) {
        await _cancelEndNotification();
      }

      try {
        // Check to see if the Reminder has scheduled notifications
        _scheduledNotifications.firstWhere((element) => element.id == lastNotificationID);
      } on StateError {
        // If not, attempt to schedule the Reminder's notifications, then break
        await _addIntervallicNotifications(reminder, updateState: false);

        // If the next Reminder is the last, check if it can be added if the end notification is cancelled
        if(i + 1 == (_intervallicReminders.length - 1)) {
          await _addLastReminderNotifications();
        }
        break;
      }
    }
  }

  // Quicksorting Pending Notification Requests with respect to nextDate (compares ID if values are equal)
  List<PendingNotificationRequest> _quicksort(List<PendingNotificationRequest> list) {
    int process(PendingNotificationRequest data) {
      return int.parse(data.payload!);
    }

    int partition() {
      final pivot = list[list.length - 1]; // Use the last element as the pivot
      final pivotPayload = process(pivot);
      final pivotID = pivot.id;

      int i = -1;

      for(int j = 0; j < list.length - 1; j++) {
        final currentPayload = process(list[j]);
        if(currentPayload < pivotPayload || (currentPayload == pivotPayload && list[j].id < pivotID)) {
          i++;
          
          // Swap list[j] and list[i]
          final tempNotif = list[j];
          list[j] = list[i];
          list[i] = tempNotif;
        }
      }

      // Swap pivot and list[i+1]
      list[list.length - 1] = list[i+1];
      list[i+1] = pivot;

      return i+1;
    }

    if(list.length > 1) {
      final pivotIndex = partition();
      return _quicksort(list.sublist(0, pivotIndex)) + [list[pivotIndex]] + _quicksort(list.sublist(pivotIndex+1));
    } else {
      return list;
    }
  }

  // Add Reminder into sorted Intervallic Reminders list
  void _addToIntervallicRemindersList(Reminder reminder) {
    int process(Reminder data) {
      return data.nextDate!.millisecondsSinceEpoch;
    }

    if(_intervallicReminders.isNotEmpty) {
      final index = _findIndex(_intervallicReminders, 0, _intervallicReminders.length - 1, reminder, process);
      _intervallicReminders.insert(index, reminder);
    } else {
      _intervallicReminders.add(reminder);
    }
  }

  // Add Pending Notification Request into sorted Scheduled Notifications List
  void _addToScheduledNotificationsList(PendingNotificationRequest request) {
    int process(PendingNotificationRequest data) {
      return int.parse(data.payload!);
    }

    if(_scheduledNotifications.isNotEmpty) {
      final index = _findIndex(_scheduledNotifications, 0, _scheduledNotifications.length - 1, request, process);
      _scheduledNotifications.insert(index, request);
    } else {
      _scheduledNotifications.add(request);
    }
  }

  // Binary search algorithm to find the index to insert Request (compares ID if values are equal)
  int _findIndex(List<dynamic> list, int min, int max, dynamic x, Function process) {
    final xData = process(x);

    if(min == max) {
      final listMin = process(list[min]);
      // If list[min] is smaller than xData, return index to the right
      if(listMin < xData) {
        return min + 1;
      } else if(listMin > xData) {
        // If list[min] is greater than xData, return current index
        return min;
      } else {
        // If they are equal, compare IDs
        if(list[min].id < x.id) {
          return min + 1;
        } else {
          return min;
        }
      }
    } else {
      // Checking if (mid + 1) is suitable to insert
      final mid = ((min + max) / 2).floor();

      // If list[mid] is greater than xData (or they are equal but list[mid] has a greater ID), repeat with left half of remaining list
      if(process(list[mid]) > xData || (process(list[mid]) == xData && list[mid].id > x.id)) {
        return _findIndex(list, min, mid, x, process);
      } else if(process(list[mid + 1]) < xData || (process(list[mid + 1]) == xData && list[mid + 1].id < x.id)) {
        // If list[mid + 1] is smaller than xData (or they are equal but list[mid] has a smaller ID), repeat with right half of remaining list
        return _findIndex(list, mid + 1, max, x, process);
      } else {
        return mid + 1;
      }
    }
  }

  // Getters (mainly for testing)
  List<Reminder> get dailyReminders {
    return _dailyReminders;
  }

  List<Reminder> get intervallicReminders {
    return _intervallicReminders;
  }

  List<PendingNotificationRequest> get dailyNotifications {
    return _dailyNotifications;
  }

  List<PendingNotificationRequest> get scheduledNotifications {
    return _scheduledNotifications;
  }
}