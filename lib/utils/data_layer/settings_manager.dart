import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

// Managing the settings of the app via shared preferences
class SettingsManager {
  SettingsManager._(); // Private constructor
  static final SettingsManager _settingsManagerSingleton = SettingsManager._();

  Settings settings = Settings();

  factory SettingsManager() {
    return _settingsManagerSingleton;
  }
}

// Settings object
// 1. Alert Time - Determines the time when notifications will fire. Defaults to 8am.
// 2. Reminder Group List Order - Determines the UI order of the Reminder Group List.
// 3. App Theme - Determines the colour scheme of the app.
class Settings {
  SharedPreferences? _prefs;

  DateTime? _alertTime;
  String _alertTimeKey = 'alert_time';

  List<int>? _uiGroupListOrder; // List of Reminder Group IDs
  String _uiGroupListOrderKey = 'group_list_order';

  String? _appTheme; // Key of AppTheme dictionary
  String _themeKey = 'theme_key';

  // Lazy getter function. Not an actual getter because async setters are not allowed
  Future<DateTime> getAlertTime() async {
    if(_alertTime != null) {
      return _alertTime!;
    }

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final alertTimeString = prefs.getString(_alertTimeKey) ?? null;

    if(alertTimeString != null) {
      final splitTimeString = alertTimeString.split(":"); // "8:00"

      // DateTime(year, month, day, hour, minute). We only need hours and minutes
      _alertTime = DateTime(0, 0, 0, int.parse(splitTimeString[0]), int.parse(splitTimeString[1]));
    } else {
      _alertTime = DateTime(0, 0, 0, 8, 0); // Default value of 0800H
    }
    return _alertTime!;
  }

  void setAlertTime(DateTime newAlertTime) async {
    _alertTime = newAlertTime;

    // Update shared preferences
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    final String alertTimeString = newAlertTime.hour.toString() + ":" + newAlertTime.minute.toString();
    prefs.setString(_alertTimeKey, alertTimeString);
  }

  Future<List<int>> getUIGroupListOrder() async {
    if(_uiGroupListOrder != null) {
      return _uiGroupListOrder!;
    }

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final orderStringList = prefs.getStringList(_uiGroupListOrderKey) ?? null;

    if(orderStringList != null) {
      _uiGroupListOrder = orderStringList.map((element) => int.parse(element)).toList();
    } else {
      _uiGroupListOrder = [];
    }

    return _uiGroupListOrder!;
  }

  void setUIGroupListOrder(List<int> newListOrder) async {
    _uiGroupListOrder = newListOrder;

    // Update shared preferences
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    final List<String> newOrderStringList = newListOrder.map((element) => element.toString()).toList();
    prefs.setStringList(_uiGroupListOrderKey, newOrderStringList);
  }

  Future<String> getAppTheme() async {
    if(_appTheme != null) {
      return _appTheme!;
    }

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _appTheme = prefs.getString(_themeKey) ?? 'dark';

    return _appTheme!;
  }

  void setAppTheme(String newTheme) async {
    _appTheme = newTheme;

    // Update shared preferences
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    prefs.setString(_themeKey, newTheme);
  }
}