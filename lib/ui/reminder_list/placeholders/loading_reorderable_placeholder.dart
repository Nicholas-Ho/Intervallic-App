import 'package:flutter/material.dart';

import 'shimmer_loading_list.dart';

// Placeholder to show while the Reorderable list fetches data
class LoadingReorderablePlaceholderState {
  static final state = LoadingReorderablePlaceholderState._(); // Singleton
  LoadingReorderablePlaceholderState._();

  Widget placeholder = ShimmerLoadingList();

  void updatePlaceholder(Widget newPlaceholder) {
    placeholder = newPlaceholder;
  }
}

class LoadingReorderablePlaceholder extends StatelessWidget {
  const LoadingReorderablePlaceholder({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingReorderablePlaceholderState.state.placeholder;
  }
}