import 'package:flutter/material.dart';

import '../pages/intervallic_page.dart';
import '../pages/reorder_page.dart';
import '../pages/settings_page.dart';

enum AppPage { // Enumerator for navigation pages
  intervallicPage, reorderPage, settingsPage
}

class NavigationManager extends ChangeNotifier {
  static final NavigationManager _navigationManager = NavigationManager._();
  NavigationManager._();

  factory NavigationManager() {
    return _navigationManager;
  }

  // A dictionary mapping the AppPage enumerator to Page Scaffolds
  final Map<AppPage, Widget> pageDict = {
    AppPage.intervallicPage: IntervallicPage(),
    AppPage.reorderPage: ReorderPage(),
    AppPage.settingsPage: SettingsPage(),
  };

  // Defaults to Intervallic Page
  List<AppPage> _pageStackTags = [AppPage.intervallicPage];

  List<Widget> get pageStack {
    return [
      for(int i = 0; i < _pageStackTags.length; i++)
        pageDict[_pageStackTags[i]]!
    ];
  }

  // Provide the BuildContext if navigating via the Navigation Drawer.
  // BuildContext not required for ReorderPage (since it should feel in-place)
  void changePage(AppPage newPage, {BuildContext? drawerContext}) {
    if(_pageStackTags[0] != newPage) {
      if(drawerContext != null) {
        Navigator.of(drawerContext).pop();
      }
      _pageStackTags = [newPage];
    }

    notifyListeners();
  }
}