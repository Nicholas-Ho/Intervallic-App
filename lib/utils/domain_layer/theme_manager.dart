import 'package:flutter/material.dart';

import '../data_layer/settings_manager.dart';
import 'package:intervallic_app/themes.dart';

class ThemeManager extends ChangeNotifier {
  AppTheme? _appTheme;

  ThemeManager(String? themeKey){
    final theme = themeKey;
    _appTheme = themeDict[theme];
  }

  AppTheme get appTheme => _appTheme!;

  void setTheme(String themeKey) {
    _appTheme = themeDict[themeKey];
    notifyListeners();
    SettingsManager().settings.setAppTheme(themeKey);
  }
}