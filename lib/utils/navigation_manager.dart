import 'package:flutter/material.dart';

import '../pages/intervallic_page.dart';
import '../pages/reorder_page.dart';

enum AppPage { // Enumerator for navigation pages
  intervallicPage, reorderPage
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
  };

  // Defaults to Intervallic Page
  AppPage _currentPageTag = AppPage.intervallicPage;

  Widget get currentPage {
    return pageDict[_currentPageTag]!;
  }

  void changePage(AppPage newPage) {
    if(_currentPageTag != newPage) {
      _currentPageTag = newPage;
    }
    notifyListeners();
  }
}