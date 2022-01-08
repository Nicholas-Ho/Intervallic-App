import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

import 'utils/data_layer/settings_manager.dart';

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

class AppTheme {
  final ThemeData? themeData;

  // Colour data for reminder tiles
  final Color? duePrimaryColour; // 'Due' referring to 'not due yet'!
  final Color? dueSecondaryColour;
  final Color? overduePrimaryColour;
  final Color? overdueSecondaryColour;

  // Colour data for drawers
  final Color? drawerPrimaryColour;
  final Color? drawerSecondaryColour;

  // Colour data for reordering page
  final Color? reorderBackgroundColour;

  AppTheme({
    this.themeData,
    this.duePrimaryColour,
    this.dueSecondaryColour,
    this.overduePrimaryColour,
    this.overdueSecondaryColour,
    this.drawerPrimaryColour,
    this.drawerSecondaryColour,
    this.reorderBackgroundColour
  });
}


final themeDict = {
  'intervallic': AppTheme(
            themeData: ThemeData(
              brightness: Brightness.light,

              primaryColor: Color(0xff00b0f0),
              primaryColorLight: Color(0xff66e2ff),
              primaryColorDark: Color(0xff0081bd),

              accentColor: Color(0xffffffff), // 0xff304ffe, 0xffff4081

              fontFamily: 'VAGRounded',
            ),

            duePrimaryColour: Color(0xff99FF99),
            dueSecondaryColour: Colors.black,
            overduePrimaryColour: Color(0xffec1c24),
            overdueSecondaryColour: Colors.white,

            drawerPrimaryColour: Color(0xff005cb2),
            drawerSecondaryColour: Colors.white,

            reorderBackgroundColour: Colors.grey
          ),
  'dark': AppTheme(
            themeData: ThemeData(
              brightness: Brightness.dark,

              primaryColor: Color(0xff0F0F16), // 0xff263238
              primaryColorLight: Color(0xff66e2ff),
              primaryColorDark: Color(0xff0081bd),

              accentColor: Color(0xff002171),

              fontFamily: 'VAGRounded',
            ),
            duePrimaryColour: Color(0xff2e7d32),
            dueSecondaryColour: Colors.white,
            overduePrimaryColour: Color(0xffbf360c),
            overdueSecondaryColour: Colors.white,

            drawerPrimaryColour: Color(0xff263238),
            drawerSecondaryColour: Colors.white,

            reorderBackgroundColour: Color(0xff363640)
          ),
};

// Green: 0xff99FF99
// Red: 0xffec1c24
// Orange: 0xffffcc66