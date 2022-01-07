import 'package:flutter/material.dart';

import 'shimmer_loading_list.dart';
import 'package:intervallic_app/models/models.dart';

// Placeholder to show while the Reorderable list fetches data
class LoadingReorderablePlaceholderState {
  static final state = LoadingReorderablePlaceholderState._(); // Singleton
  LoadingReorderablePlaceholderState._();

  Widget placeholder = ShimmerLoadingList();

  void updatePlaceholder(List<ReminderGroup> reminderGroupList) {
    placeholder = ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: reminderGroupList.length,
      itemBuilder: (context, index) {
        // Copy of ReminderListReorderable state's buildTile()
        final reminderGroup = reminderGroupList[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 60,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(reminderGroup.name!, style: TextStyle(fontSize: 20)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.reorder),
                      )
                    ]
                  ),
                ),
              ),
            ),
        );
      },
      padding: const EdgeInsets.all(10),
    );
  }
}

class LoadingReorderablePlaceholder extends StatelessWidget {
  const LoadingReorderablePlaceholder({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingReorderablePlaceholderState.state.placeholder;
  }
}