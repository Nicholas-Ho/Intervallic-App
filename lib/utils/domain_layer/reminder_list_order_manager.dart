import 'package:flutter/material.dart';

import '../data_layer/settings_manager.dart';

class ReminderListOrderManager extends ChangeNotifier {
  final Settings settings = SettingsManager().settings;

  List<int>? _cachedOrder; // Storing list order to update

  void beginReorder() {
    _cachedOrder = null;
  }

  void endReorder() async {
    // Only push if changes were made
    if(_cachedOrder != null) {
      settings.setUIGroupListOrder(_cachedOrder!);
    }
  }

  void cancelReorder() async {
    _cachedOrder = null;
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