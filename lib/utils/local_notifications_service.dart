import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static LocalNotificationService _localNotificationService = LocalNotificationService._();
  final FlutterLocalNotificationsPlugin _localNotificationPlugin = FlutterLocalNotificationsPlugin();

  factory LocalNotificationService() {
    return _localNotificationService;
  }

  LocalNotificationService._();

  void init() async {
    // Android
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    // iOS
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null,
    );

    tz.initializeTimeZones();

    await _localNotificationPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onSelectNotification,
    );
  }

  Future _onSelectNotification(String? payload) async {
    // Notification tapped logic
  }

  Future _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async{
    // Callback for iOS 10 and below for local notifications in the foreground
  }

  Future<void> scheduleNotification(int id, String? title, String? body, DateTime scheduledDate, {String? payload}) async {
    await _localNotificationPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            '1',
            'Intervallic App Channel',
            'Intervallic App Local Notifications',
            priority: Priority.defaultPriority,
            importance: Importance.high,
            fullScreenIntent: true)),
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true);
  }

  Future<void> scheduleRepeatingNotification(int id, String? title, String? body, DateTime scheduledDate, {String? payload, String mode = 'Daily'}) async {
    DateTimeComponents repeatingComponentMatch;
    switch(mode) {
      case 'Daily': { repeatingComponentMatch = DateTimeComponents.time; }
      break;

      case 'Weekly': { repeatingComponentMatch = DateTimeComponents.dayOfWeekAndTime; }
      break;

      default: { repeatingComponentMatch = DateTimeComponents.time; } // Defaults to daily
      break;
    }

    await _localNotificationPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            '1',
            'Intervallic App Channel',
            'Intervallic App Local Notifications',
            priority: Priority.defaultPriority,
            importance: Importance.high,
            fullScreenIntent: true)),
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatingComponentMatch, // Repeats daily at the matched time
      androidAllowWhileIdle: true);
  }

  Future<void> cancelNotification(int id) async {
    await _localNotificationPlugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    return await _localNotificationPlugin.pendingNotificationRequests();
  }

  Future<void> clearAll() async {
    await _localNotificationPlugin.cancelAll();
  }
}