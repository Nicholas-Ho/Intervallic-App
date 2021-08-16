import 'package:flutter/material.dart';

import '../data_layer/settings_manager.dart';

class ReminderListOrderManager extends ChangeNotifier {
  final Settings settings = SettingsManager().settings;
  bool _isReordering = false;

  List<int>? _cachedOrder; // Storing list order to update

  bool get isReordering {
    return _isReordering;
  }

  void beginReorder() {
    _isReordering = true;
    _cachedOrder = null;
    notifyListeners();
  }

  void endReorder() async {
    _isReordering = false;

    // Only push if changes were made
    if(_cachedOrder != null) {
      settings.setUIGroupListOrder(_cachedOrder!);
    }

    notifyListeners();
  }

  // Updates the cached list order. Does NOT update shared preferences (only updated on endReorder)
  void updateUIGroupListOrder(List<int> newListOrder) {
    _cachedOrder = newListOrder;
  }

  // Interfacing with the settings
  Future<List<int>> getUIGroupListOrder() async {
    if(_cachedOrder == null) {
      _cachedOrder = await settings.getUIGroupListOrder();
    }
    return _cachedOrder!;
  }
}