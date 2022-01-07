import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class ThemeManager extends ChangeNotifier {

}

class AppTheme {
  final String? themeKey;

  final ThemeData? themeData;

  // Colour data for reminder tiles
  final Color? duePrimaryColour; // 'Due' referring to 'not due yet'!
  final Color? dueSecondaryColour;
  final Color? overduePrimaryColour;
  final Color? overdueSecondaryColour;

  AppTheme({
    this.themeKey,
    this.themeData,
    this.duePrimaryColour,
    this.dueSecondaryColour,
    this.overduePrimaryColour,
    this.overdueSecondaryColour
  });
}

final intervallicTheme = ThemeData(
  brightness: Brightness.light,

  primaryColor: Color(0xff00b0f0),
  primaryColorLight: Color(0xff66e2ff),
  primaryColorDark: Color(0xff0081bd),

  accentColor: Color(0xffffffff), // 0xff304ffe, 0xffff4081

  fontFamily: 'VAGRounded',
);

/*
final intervallicTheme = AppTheme(
  themeKey: 'intervallic',
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
  overdueSecondaryColour: Colors.white
);*/

final darkTheme = ThemeData(
  brightness: Brightness.dark,

  primaryColor: Color(0xff000000),
  primaryColorLight: Color(0xff66e2ff),
  primaryColorDark: Color(0xff0081bd),

  accentColor: Color(0xffffffff), // 0xff304ffe, 0xffff4081

  fontFamily: 'VAGRounded',
);

// Green: 0xff99FF99
// Red: 0xffec1c24
// Orange: 0xffffcc66