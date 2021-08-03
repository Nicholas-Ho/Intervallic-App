import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/local_notification_manager.dart';
import 'package:intervallic_app/utils/local_notifications_service.dart';

void main() {
  final int daysToRemind = 7;
  group('Basic functions tests.', () {
    LocalNotificationManager? localNotificationManager;
    Map<ReminderGroup, List<Reminder>>? reminderData;
    final DateTime now = DateTime.now();

    setUp(() {
      localNotificationManager = LocalNotificationManager();
      localNotificationManager!.localNotificationService = MockLocalNotificationService();

      // Setting up Reminder Data
      ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
      ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
      ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");
      Reminder doYoga = Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 3)),
          description: null);
      Reminder waterPlants = Reminder(
          id: 2,
          name: "Water the Plants",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 7)),
          description: null);
      Reminder nelson = Reminder(
          id: 3,
          name: "Call Nelson",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 7)),
          description: null);
      Reminder kexin = Reminder(
          id: 4,
          name: "Call Kexin",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.days,
          nextDate: now.add(Duration(days: 7)),
          description: null);

      reminderData = {
        dailyReminders: [doYoga, waterPlants],
        keepInTouch: [nelson, kexin],
        miscellaneous: []
      };

      // Setting up Pending Notification Requests for Mock Plugin
      final reminders = [doYoga, nelson, kexin, waterPlants];
      final service = localNotificationManager!.localNotificationService;
      reminders.forEach((element) {
        if(element.intervalValue == 1 && element.intervalType == IntervalType.days) {
          service.scheduleRepeatingNotification(
            element.id! * 10,
            'Reminder',
            "'${element.name}' is overdue!",
            element.nextDate!);
        } else {
          for(int i = 0; i < daysToRemind; i++) {
            service.scheduleNotification(
              element.id! * 10 + 1 + i,
              'Reminder',
              "'${element.name}' is overdue!",
              element.nextDate!,
              payload: element.nextDate!.add(Duration(days: i)).millisecondsSinceEpoch.toString());
          }
        }
      });
    });

    tearDown(() {}); // TearDown not required as localNotificationManager is reinitialised in setUp

    test('Test init, part 1 - receiving and sorting data.', () async {
      await localNotificationManager!.init(reminderData!, resolveUpdates: false);

      // Assert the Manager's internal state
      expect(localNotificationManager!.dailyReminders.length, 1);
      expect(localNotificationManager!.intervallicReminders, [
        Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 3)),
          description: null),
        Reminder(
          id: 2,
          name: "Water the Plants",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 7)),
          description: null),
        Reminder(
          id: 3,
          name: "Call Nelson",
          reminderGroupID: 2,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 7)),
          description: null),
      ]);

      // Assert the daily notification length
      expect(localNotificationManager!.dailyNotifications.length, 1);

      // Assert the intervallic notification length
      final scheduledNotifs = localNotificationManager!.scheduledNotifications;
      expect(scheduledNotifs.length, daysToRemind * 3);

      // Check if the sorting algorithm is working
      for(int i = 1; i < scheduledNotifs.length; i++) {
        final beforePayload = int.parse(scheduledNotifs[i-1].payload!);
        final afterPayload = int.parse(scheduledNotifs[i].payload!);
        final bool isGreater = (afterPayload > beforePayload) ||
            (afterPayload == beforePayload && scheduledNotifs[i].id > scheduledNotifs[i-1].id);
        expect(isGreater, true);
      }
    });

    test('Test for addDailyNotification.', () async {
      await localNotificationManager!.init(reminderData!, resolveUpdates: false);

      final data = Reminder(
        id: 10,
        name: 'Program Intervallic',
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: IntervalType.days,
        nextDate: now.add(Duration(days: 7)),
        description: null,
      );
      await localNotificationManager!.addNotifications(data);

      // Check Manager's internal state
      expect(localNotificationManager!.dailyReminders[1], data);

      // Check that notification has been added
      final dailyNotifications = localNotificationManager!.dailyNotifications;
      expect(findByID(dailyNotifications, 100, notFoundMessage: 'Notification not found in Manager'), true);

      final pendingNotifications = await localNotificationManager!.localNotificationService.getPendingNotificationRequests();
      expect(findByID(pendingNotifications, 100, notFoundMessage: 'Notification not found in Service'), true);
    });

    test('Test for addIntervallicNotifications', () async {
      await localNotificationManager!.init(reminderData!, resolveUpdates: false);

      final data = Reminder(
        id: 10,
        name: 'Program Intervallic',
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 7)),
        description: null,
      );
      await localNotificationManager!.addNotifications(data);

      // Check Manager's internal state (binary search sorted add)
      expect(localNotificationManager!.intervallicReminders[3], data);

      // Check that notification has been added
      final scheduledNotifications = localNotificationManager!.scheduledNotifications;
      final pendingNotifications = await localNotificationManager!.localNotificationService.getPendingNotificationRequests();
      for(int i = 0; i < daysToRemind; i++) {
        final id = 101 + i;
        expect(findByID(scheduledNotifications, id, notFoundMessage: 'Notification not found in Manager'), true);
        expect(findByID(pendingNotifications, id, notFoundMessage: 'Notification not found in Service'), true);
      }

      final scheduledNotifs = localNotificationManager!.scheduledNotifications;
      expect(scheduledNotifs.length, daysToRemind * 4);

      // Check if the sorting algorithm is working
      for(int i = 1; i < scheduledNotifs.length; i++) {
        expect((int.parse(scheduledNotifs[i].payload!) >= int.parse(scheduledNotifs[i-1].payload!)), true);
      }
    });

    test('Test for cancelDailyNotification.', () async {
      await localNotificationManager!.init(reminderData!, resolveUpdates: false);

      final data = Reminder(
        id: 4,
        name: "Call Kexin",
        reminderGroupID: 2,
        intervalValue: 1,
        intervalType: IntervalType.days,
        nextDate: now.add(Duration(days: 7)),
        description: null
      );

      await localNotificationManager!.cancelNotifications(data);

      // Check Manager's internal state
      expect(localNotificationManager!.dailyReminders.length, 0);

      // Check that notification has been cancelled
      final dailyNotifications = localNotificationManager!.dailyNotifications;
      expect(findByID(dailyNotifications, 40, foundMessage: 'Notification was found in Manager'), false);

      final pendingNotifications = await localNotificationManager!.localNotificationService.getPendingNotificationRequests();
      expect(findByID(pendingNotifications, 40, foundMessage: 'Notification was found in Service'), false);
    });

    test('Test for cancelIntervallicNotifications.', () async {
      await localNotificationManager!.init(reminderData!, resolveUpdates: false);

      final data = Reminder(
        id: 2,
        name: "Water the Plants",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 7)),
        description: null
      );

      await localNotificationManager!.cancelNotifications(data);

      // Check Manager's internal state (binary search sorted add)
      expect(localNotificationManager!.intervallicReminders.contains(data), false);

      // Check that notification has been cancelled
      final scheduledNotifications = localNotificationManager!.scheduledNotifications;
      final pendingNotifications = await localNotificationManager!.localNotificationService.getPendingNotificationRequests();

      for(int i = 0; i < daysToRemind; i++) {
        final id = 21 + i;
        expect(findByID(scheduledNotifications, id, foundMessage: 'Notification was found in Manager'), false);
        expect(findByID(pendingNotifications, id, foundMessage: 'Notification was found in Service'), false);
      }

      final scheduledNotifs = localNotificationManager!.scheduledNotifications;
      expect(scheduledNotifs.length, daysToRemind * 2);

      // Check if the sorting algorithm is working
      for(int i = 1; i < scheduledNotifs.length; i++) {
        expect((int.parse(scheduledNotifs[i].payload!) >= int.parse(scheduledNotifs[i-1].payload!)), true);
      }
    });
  });

  test('Test init, part 2 - resolving discrepancies', () async {
    // Set-up
    LocalNotificationManager localNotificationManager = LocalNotificationManager();
    localNotificationManager.localNotificationService = MockLocalNotificationService();
    final now = DateTime.now();

    // Setting up Reminder Data
    ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
    ReminderGroup keepInTouch = ReminderGroup(id: 2, name: "Keep In Touch");
    ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");
    Reminder doYoga = Reminder(
        id: 1,
        name: "Do Yoga",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 3)),
        description: null);
    Reminder waterPlants = Reminder(
        id: 2,
        name: "Water the Plants",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 7)),
        description: null);
    Reminder nelson = Reminder(
        id: 3,
        name: "Call Nelson",
        reminderGroupID: 2,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 7)),
        description: null);
    Reminder kexin = Reminder(
        id: 4,
        name: "Call Kexin",
        reminderGroupID: 2,
        intervalValue: 1,
        intervalType: IntervalType.days,
        nextDate: now.add(Duration(days: 7)),
        description: null);

    final Map<ReminderGroup, List<Reminder>> reminderData = {
      dailyReminders: [doYoga, waterPlants],
      keepInTouch: [nelson, kexin],
      miscellaneous: []
    };

    // Setting up Pending Notification Requests for Mock Plugin
    final reminders = [doYoga, nelson, kexin]; // Dropping waterPlants to check if the Manager adds it
    final service = localNotificationManager.localNotificationService;
    reminders.forEach((element) {
      if(element.intervalValue == 1 && element.intervalType == IntervalType.days) {
        service.scheduleRepeatingNotification(
          element.id! * 10,
          'Reminder',
          "'${element.name}' is overdue!",
          element.nextDate!);
      } else {
        for(int i = 0; i < daysToRemind; i++) {
          service.scheduleNotification(
            element.id! * 10 + 1 + i,
            'Reminder',
            "'${element.name}' is overdue!",
            element.nextDate!,
            payload: element.nextDate!.add(Duration(days: i)).millisecondsSinceEpoch.toString()
          );
        }
      }
    });

    // Initialising
    await localNotificationManager.init(reminderData);

    // Assert the intervallic notification length
    final scheduledNotifs = localNotificationManager.scheduledNotifications;
    expect(scheduledNotifs.length, daysToRemind * 3);

    // Check if the notifications have been added
    final scheduledNotifications = localNotificationManager.scheduledNotifications;
    final pendingNotifications = await localNotificationManager.localNotificationService.getPendingNotificationRequests();
    for(int i = 0; i < daysToRemind; i++) {
      final id = 21 + i;
      expect(findByID(scheduledNotifications, id, notFoundMessage: 'Notification not found in Manager'), true);
      expect(findByID(pendingNotifications, id, notFoundMessage: 'Notification not found in Manager'), true);
    }
  });

  group('Stress testing - tests with a full notification queue.', () {
    final DateTime now = DateTime.now();
    LocalNotificationManager? localNotificationManager;

    Reminder? lateReminder;
    Reminder? pastReminder;
    int? lateNotificationID;

    setUp(() async {
      localNotificationManager = LocalNotificationManager();
      localNotificationManager!.localNotificationService = MockLocalNotificationService();

      // One Reminder that is far into the future, one that is past (so no notifications), the rest are dummy to fill space
      lateReminder = Reminder(
        id: 1,
        name: "Late Reminder",
        reminderGroupID: 3,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 21)),
        description: null);

      lateNotificationID = 10 + daysToRemind;

      pastReminder = Reminder(
        id: 2,
        name: "Past Reminder",
        reminderGroupID: 3,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.subtract(Duration(days: 14)),
        description: null);

      List<Reminder> dummyReminders = [];
      int id = 3;
      int notificationQuantity = daysToRemind;
      while(notificationQuantity <= (LocalNotificationManager.maxNotifications - 2 * daysToRemind)) {
        dummyReminders.add(
          Reminder(
            id: id,
            name: "Dummy Reminder",
            reminderGroupID: 3,
            intervalValue: 1,
            intervalType: IntervalType.weeks,
            nextDate: now.add(Duration(days: 3)),
            description: null)
        );
        id++;
        notificationQuantity += daysToRemind;
      }

      while(notificationQuantity < LocalNotificationManager.maxNotifications) {
        dummyReminders.add(
          Reminder(
            id: id,
            name: "Dummy Reminder",
            reminderGroupID: 3,
            intervalValue: 1,
            intervalType: IntervalType.days,
            nextDate: now.add(Duration(days: 1)),
            description: null)
        );
        id++;
        notificationQuantity++;
      }

      ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");

      Map<ReminderGroup, List<Reminder>> reminderData = {
        miscellaneous: [lateReminder!, pastReminder!] + dummyReminders
      };

      await localNotificationManager!.init(reminderData);
    });

    test('Check if set-up is correct', () {
      // Check if the setup is correct (notification queue full)
      final initialDailyLength = localNotificationManager!.dailyNotifications.length;
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      final totalLength = initialDailyLength + initialScheduledLength;

      expect(totalLength, LocalNotificationManager.maxNotifications);
      expect(localNotificationManager!.scheduledNotifications.length > 1, true);
    });

    test('Test for daily notifications methods.', () async {
      final initialDailyLength = localNotificationManager!.dailyNotifications.length;
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Test for adding a daily Reminder.
      final dailyReminder = Reminder(
        id: 100,
        name: "Daily Reminder",
        reminderGroupID: 3,
        intervalValue: 1,
        intervalType: IntervalType.days,
        nextDate: now.add(Duration(days: 7)),
        description: null);
      await localNotificationManager!.addNotifications(dailyReminder);

      // "Daily Reminder" notification should be added. Check.
      expect(localNotificationManager!.dailyNotifications.length, initialDailyLength + 1);
      expect(localNotificationManager!.dailyReminders.contains(dailyReminder), true);
      expect(findByID(localNotificationManager!.dailyNotifications, 1000), true);

      //  "Late Reminder" notifications should be deleted, but the Reminder itself should exist in the Manager State. Check.
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength - daysToRemind);
      expect(localNotificationManager!.intervallicReminders.contains(lateReminder!), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, lateNotificationID!), false);

      // The end notification should be added. Check.
      expect(localNotificationManager!.endNotification != null, true);



      // Test for cancelling a daily Reminder
      await localNotificationManager!.cancelNotifications(dailyReminder);
      
      // "Daily Reminder" notification should be cancelled. Check.
      expect(localNotificationManager!.dailyNotifications.length, initialDailyLength);
      expect(localNotificationManager!.dailyReminders.contains(dailyReminder), false);
      expect(findByID(localNotificationManager!.dailyNotifications, 1000), false);

      //  "Late Reminder" notifications should be re-added. Check.
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength);
      expect(localNotificationManager!.intervallicReminders.contains(lateReminder), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, lateNotificationID!), true);

      // The end notification should be cancelled. Check.
      expect(localNotificationManager!.endNotification != null, false);
    });

    test('Test for scheduled notifications methods, part 1 - successful add.', () async {
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Test for adding an intervallic Reminder.
      final intervallicReminder = Reminder(
        id: 100,
        name: "Intervallic Reminder",
        reminderGroupID: 3,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 1)), // Before dummy reminders
        description: null);
      final intervallicReminderID = 1000 + daysToRemind;

      await localNotificationManager!.addNotifications(intervallicReminder);

      // + "Intervallic Reminder", - "Late Reminder", - 1 x "Dummy Reminder" (to make space for end notification)
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength - daysToRemind);

      // "Intervallic Reminder" notification should be added. Check.
      expect(localNotificationManager!.intervallicReminders.contains(intervallicReminder), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, intervallicReminderID), true);

      //  "Late Reminder" notifications should be cancelled, but the Reminder itself should exist in the Manager State. Check.
      expect(localNotificationManager!.intervallicReminders.contains(lateReminder!), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, lateNotificationID!), false);

      // The end notification should be added. Check.
      expect(localNotificationManager!.endNotification != null, true);



      // Test for cancelling an intervallic Reminder
      await localNotificationManager!.cancelNotifications(intervallicReminder);

      // + "Late Reminder", + 1 x "Dummy Reminder", - "Intervallic Reminder"
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength);
      
      // "Intervallic Reminder" notification should be cancelled. Check.
      expect(localNotificationManager!.intervallicReminders.contains(intervallicReminder), false);
      expect(findByID(localNotificationManager!.scheduledNotifications, intervallicReminderID), false);

      //  "Late Reminder" notifications should be re-added. Check.
      expect(localNotificationManager!.intervallicReminders.contains(lateReminder), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, lateNotificationID!), true);

      // The end notification should be cancelled. Check.
      expect(localNotificationManager!.endNotification != null, false);
    });

    test('Test for scheduled notifications methods, part 2 - unsuccessful add.', () async {
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Test for adding an intervallic Reminder.
      final intervallicReminder = Reminder(
        id: 100,
        name: "Intervallic Reminder",
        reminderGroupID: 3,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 28)), // After late reminder
        description: null);
      final intervallicReminderID = 1000 + daysToRemind;

      await localNotificationManager!.addNotifications(intervallicReminder);

      // - "Late Reminder"(to make space for end notification)
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength - daysToRemind);

      // "Intervallic Reminder" notification should not be added, but the Reminder itself should exist in the Manager State. Check.
      expect(localNotificationManager!.intervallicReminders.contains(intervallicReminder), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, intervallicReminderID), false);

      //  "Late Reminder" notifications should be cancelled, but the Reminder itself should exist in the Manager State. Check.
      expect(localNotificationManager!.intervallicReminders.contains(lateReminder!), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, lateNotificationID!), false);

      // The end notification should be added. Check.
      expect(localNotificationManager!.endNotification != null, true);



      // Test for cancelling an intervallic Reminder
      await localNotificationManager!.cancelNotifications(intervallicReminder);

      // + "Late Reminder"
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength);
      
      // "Intervallic Reminder" notification should not be added, and the Reminder should be removed from Manager's state. Check.
      expect(localNotificationManager!.intervallicReminders.contains(intervallicReminder), false);
      expect(findByID(localNotificationManager!.scheduledNotifications, intervallicReminderID), false);

      //  "Late Reminder" notifications should be re-added. Check.
      expect(localNotificationManager!.intervallicReminders.contains(lateReminder), true);
      expect(findByID(localNotificationManager!.scheduledNotifications, lateNotificationID!), true);

      // The end notification should be cancelled. Check.
      expect(localNotificationManager!.endNotification != null, false);
    });

    test("Test for scheduled notifications methods, part 3 - cancelling a past reminder's notifications.", () async {
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Test for cancelling a past Reminder
      await localNotificationManager!.cancelNotifications(pastReminder!);

      // No Change
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength);

      // The end notification should be not be added. Check.
      expect(localNotificationManager!.endNotification != null, false);
    });
  });

  group('Tests for updating methods.', () {
    LocalNotificationManager? localNotificationManager;
    final DateTime now = DateTime.now();
    Reminder? doYoga;
    Reminder? kexin;

    setUp(() {
      localNotificationManager = LocalNotificationManager();
      localNotificationManager!.localNotificationService = MockLocalNotificationService();

      // Setting up Reminder Data
      ReminderGroup dailyReminders = ReminderGroup(id: 1, name: "Daily Reminders");
      ReminderGroup miscellaneous = ReminderGroup(id: 3, name: "Miscellaneous");
      doYoga = Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 3,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 3)),
          description: null);
      kexin = Reminder(
          id: 4,
          name: "Call Kexin",
          reminderGroupID: 1,
          intervalValue: 1,
          intervalType: IntervalType.days,
          nextDate: now.add(Duration(days: 7)),
          description: null);

      Map<ReminderGroup, List<Reminder>> reminderData = {
        dailyReminders: [kexin!],
        miscellaneous: [doYoga!]
      };

      // Setting up Pending Notification Requests for Mock Plugin
      final reminders = [doYoga, kexin];
      final service = localNotificationManager!.localNotificationService;
      reminders.forEach((element) {
        if(element!.intervalValue == 1 && element.intervalType == IntervalType.days) {
          service.scheduleRepeatingNotification(
            element.id! * 10,
            'Reminder',
            "'${element.name}' is overdue!",
            element.nextDate!);
        } else {
          for(int i = 0; i < daysToRemind; i++) {
            service.scheduleNotification(
              element.id! * 10 + 1 + i,
              'Reminder',
              "'${element.name}' is overdue!",
              element.nextDate!,
              payload: element.nextDate!.add(Duration(days: i)).millisecondsSinceEpoch.toString());
          }
        }
      });

      localNotificationManager!.init(reminderData);
    });
  
    test('Test for updateDailyNotification, part 1 - change of name.', () async {
      final initialDailyLength = localNotificationManager!.dailyNotifications.length;
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Changed name from "Call Kexin" to "Call Wilson"
      final updatedReminder = Reminder(
        id: 4,
        name: "Call Wilson",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: IntervalType.days,
        nextDate: now.add(Duration(days: 7)),
        description: null);

      // Update notifications
      await localNotificationManager!.updateNotifications(updatedReminder);

      // No change in number of notifications
      expect(localNotificationManager!.dailyNotifications.length, initialDailyLength);
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength);

      // Manager state contains only updated Reminder
      expect(localNotificationManager!.dailyReminders.contains(updatedReminder), true);
      expect(localNotificationManager!.dailyReminders.contains(kexin!), false);

      PendingNotificationRequest notification;
      try {
        notification = localNotificationManager!.dailyNotifications.firstWhere((element) => element.id == 40);
        expect(notification.body!, "'Call Wilson' is overdue!");
      } on StateError {
        print('Notification not found');
        expect(true, false); // Throw assertion failed
      }
    });

    test('Test for updateDailyNotification, part 2 - change to intervallic.', () async {
      final initialDailyLength = localNotificationManager!.dailyNotifications.length;
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Changed interval type from days to weeks
      final updatedReminder = Reminder(
        id: 4,
        name: "Call Kexin",
        reminderGroupID: 1,
        intervalValue: 1,
        intervalType: IntervalType.weeks,
        nextDate: now.add(Duration(days: 7)),
        description: null);

      // Update notifications
      await localNotificationManager!.updateNotifications(updatedReminder);

      // Changed notifications length
      expect(localNotificationManager!.dailyNotifications.length, initialDailyLength - 1);
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength + daysToRemind);

      // Manager state contains only updated Reminder
      expect(localNotificationManager!.intervallicReminders.contains(updatedReminder), true);
      expect(localNotificationManager!.dailyReminders.contains(kexin!), false);

      // Notification found only in scheduled notifications list
      try {
        localNotificationManager!.dailyNotifications.firstWhere((element) => element.id == 40);
        expect(true, false); // Throw assertion failed
      } on StateError {
        try {
          final id = 40 + daysToRemind;
          localNotificationManager!.scheduledNotifications.firstWhere((element) => element.id == id);
        } on StateError {
          print('Notification not found in both daily and scheduled lists.');
          expect(true, false); // Throw assertion failed
        }
      }
    });

    test('Test for updateIntervallicNotifications, part 1 - change of name.', () async {
      final initialDailyLength = localNotificationManager!.dailyNotifications.length;
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Changed name from "Do Yoga" to "Do Pilates"
      final updatedReminder = Reminder(
          id: 1,
          name: "Do Pilates",
          reminderGroupID: 3,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: now.add(Duration(days: 3)),
          description: null);

      // Update notifications
      await localNotificationManager!.updateNotifications(updatedReminder);

      // No change in number of notifications
      expect(localNotificationManager!.dailyNotifications.length, initialDailyLength);
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength);

      // Manager state contains only updated Reminder
      expect(localNotificationManager!.intervallicReminders.contains(updatedReminder), true);
      expect(localNotificationManager!.intervallicReminders.contains(doYoga!), false);

      // Check for name change
      PendingNotificationRequest notification;
      try {
        final id = 10 + daysToRemind;
        notification = localNotificationManager!.scheduledNotifications.firstWhere((element) => element.id == id);
        expect(notification.body!, "'Do Pilates' is overdue!");
      } on StateError {
        print('Notification not found');
        expect(true, false); // Throw assertion failed
      }
    });

    test('Test for updateIntervallicNotifications, part 2 - change to daily.', () async {
      final initialDailyLength = localNotificationManager!.dailyNotifications.length;
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      // Changed interval type from days to weeks
      final updatedReminder = Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 3,
          intervalValue: 1,
          intervalType: IntervalType.days,
          nextDate: now.add(Duration(days: 3)),
          description: null);

      // Update notifications
      await localNotificationManager!.updateNotifications(updatedReminder);

      // Changed notifications length
      expect(localNotificationManager!.dailyNotifications.length, initialDailyLength + 1);
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength - daysToRemind);

      // Manager state contains only updated Reminder
      expect(localNotificationManager!.dailyReminders.contains(updatedReminder), true);
      expect(localNotificationManager!.intervallicReminders.contains(doYoga!), false);

      // Notification found only in daily notifications list
      try {
        final id = 10 + daysToRemind;
        localNotificationManager!.scheduledNotifications.firstWhere((element) => element.id == id);
        expect(true, false); // Throw assertion failed
      } on StateError {
        try {
          localNotificationManager!.dailyNotifications.firstWhere((element) => element.id == 10);
        } on StateError {
          print('Notification not found in both daily and scheduled lists.');
          expect(true, false); // Throw assertion failed
        }
      }
    });

    test('Test for updateIntervallicNotifications, part 3 - change of nextDate.', () async {
      final initialDailyLength = localNotificationManager!.dailyNotifications.length;
      final initialScheduledLength = localNotificationManager!.scheduledNotifications.length;

      final newDate = now.add(Duration(days: 10));

      // Changed nextDate from (now + 3 days) to (now + 10 days)
      final updatedReminder = Reminder(
          id: 1,
          name: "Do Yoga",
          reminderGroupID: 3,
          intervalValue: 1,
          intervalType: IntervalType.weeks,
          nextDate: newDate,
          description: null);

      // Update notifications
      await localNotificationManager!.updateNotifications(updatedReminder);

      // No Change
      expect(localNotificationManager!.dailyNotifications.length, initialDailyLength);
      expect(localNotificationManager!.scheduledNotifications.length, initialScheduledLength);

      // Manager state contains only updated Reminder
      expect(localNotificationManager!.intervallicReminders.contains(updatedReminder), true);
      expect(localNotificationManager!.intervallicReminders.contains(doYoga!), false);

      // Check for date change
      PendingNotificationRequest notification;
      try {
        final id = 10 + daysToRemind;
        notification = localNotificationManager!.scheduledNotifications.firstWhere((element) => element.id == id);

        DateTime updatedDate = DateTime.fromMillisecondsSinceEpoch(int.parse(notification.payload!));
        expect(updatedDate.year, newDate.year);
        expect(updatedDate.month, newDate.month);
        expect(updatedDate.day, newDate.day + daysToRemind - 1);
      } on StateError {
        print('Notification not found');
        expect(true, false); // Throw assertion failed
      }
    });
  });
}

// Helper function to check if an Object of a certain ID is present in a list
bool findByID(List<dynamic> list, int id, {String? foundMessage, String? notFoundMessage}) {
  bool wasFound = false;
  try{
    list.firstWhere((element) => element.id == id);
    wasFound = true;
    if(foundMessage != null) {
      print(foundMessage);
    }
  } on StateError {
    wasFound = false;
    if(notFoundMessage != null) {
      print(notFoundMessage);
    }
  }
  return wasFound;
}

// Mock Notification Plugin
class MockLocalNotificationService extends Mock implements LocalNotificationService {
  List<PendingNotificationRequest> requestList = [];

  @override
  Future<void> scheduleNotification(int id, String? title, String? body, DateTime scheduledDate, {String? payload}) async {
    final index = requestList.indexWhere((element) => element.id == id);
    if(index != -1) {
      requestList.removeAt(index);
      requestList.insert(index, PendingNotificationRequest(id, title, body, payload));
    } else {
      requestList.add(PendingNotificationRequest(id, title, body, payload));
    }
  }
  
  @override
  Future<void> scheduleRepeatingNotification(int id, String? title, String? body, DateTime scheduledDate, {String? payload, String mode = 'Daily'}) async {
    final index = requestList.indexWhere((element) => element.id == id);
    if(index != -1) {
      requestList.removeAt(index);
      requestList.insert(index, PendingNotificationRequest(id, title, body, payload));
    } else {
      requestList.add(PendingNotificationRequest(id, title, body, payload));
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    final index = requestList.indexWhere((element) => element.id == id);
    if(index != -1) {
      requestList.removeAt(index);
    } else {
      print('Notification not found');
    }
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    return requestList;
  }

  @override
  Future<void> clearAll() async {
    requestList = [];
  }

  void setRequestList(List<PendingNotificationRequest> list) {
    requestList = list;
  }
}