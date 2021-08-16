import 'package:flutter/material.dart';

import '../ui/dialogs/create_new_navigation_dialog.dart';
import '../ui/reminder_list/reminder_list_reorderable.dart';
import '../ui/reminder_list/reminder_list.dart';

class IntervallicPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColour = Theme.of(context).primaryColor;

    return Scaffold(
      key: UniqueKey(),
      backgroundColor: backgroundColour,
      appBar: AppBar(
        backgroundColor: backgroundColour,
        elevation: 0,
        centerTitle: true,
        title: Text("Intervallic", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [ReminderListReorderButton()],
      ),
      body: ReminderList(), // Wrapped to switch between the Reminder List and Reorderable List
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return CreateNewNavigationDialog();
            }
            );
        },
      ),
    );
  }
}
