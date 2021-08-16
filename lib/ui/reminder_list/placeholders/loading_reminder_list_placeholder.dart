import 'package:flutter/material.dart';

import 'shimmer_loading_list.dart';

// Placeholder to show while the Reorderable list fetches data
class LoadingReminderListPlaceholderState {
  static final state = LoadingReminderListPlaceholderState._(); // Singleton
  LoadingReminderListPlaceholderState._();

  Widget placeholder = ShimmerLoadingList();

  void updatePlaceholder(Widget newPlaceholder) {
    placeholder = newPlaceholder;
  }
}

class LoadingReminderListPlaceholder extends StatelessWidget {
  const LoadingReminderListPlaceholder({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingReminderListPlaceholderState.state.placeholder;
  }
}