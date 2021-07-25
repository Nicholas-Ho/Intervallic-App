import 'package:flutter/material.dart';

import 'reminder_group_dialogs/new_reminder_group_form_dialog.dart';
import 'reminder_dialogs/new_reminder_form_dialog.dart';

class CreateNewNavigationDialog extends StatelessWidget {
  final double fontSize = 18;

  CreateNewNavigationDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            newReminderGroupFormButton(context),
            newReminderFormButton(context),
          ],
          ),
        ),
    );
  }

  Widget newReminderGroupFormButton(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        child: Text('New Reminder Group', style: TextStyle(fontSize: fontSize)),
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: Theme.of(context).primaryColorDark,
        ),
        onPressed: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return NewReminderGroupFormDialog();
            }
          );
        },
      )
    );
  }

  Widget newReminderFormButton(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        child: Text('New Reminder', style: TextStyle(fontSize: fontSize)),
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: Theme.of(context).primaryColorDark,
        ),
        onPressed: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return NewReminderFormDialog();
            }
          );
        },
      )
    );
  }
}