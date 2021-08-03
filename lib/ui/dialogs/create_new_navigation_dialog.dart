import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'reminder_group_dialogs/new_reminder_group_form_dialog.dart';
import 'reminder_dialogs/new_reminder_form_dialog.dart';
import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';

class CreateNewNavigationDialog extends StatelessWidget {
  final double fontSize = 18;

  CreateNewNavigationDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              newReminderGroupFormButton(context),
              newReminderFormButton(context),
            ],
          ),
        ),
      ]
    );
  }

  Widget newReminderGroupFormButton(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        child: Text('New Group', style: TextStyle(fontSize: fontSize)),
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
    void buttonOnPressed() {
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return NewReminderFormDialog();
        }
      );
    }

    Widget button(bool enabled) {
      // If disabled, change the button colour and make onPressed do nothing
      return ElevatedButton(
        child: Text('New Reminder', style: TextStyle(fontSize: fontSize)),
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: enabled ? Theme.of(context).primaryColorDark : Theme.of(context).disabledColor,
        ),
        onPressed: () => enabled ? buttonOnPressed : null,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Consumer<ReminderDataState>( // Requires Consumer to check if Reminder Data is empty
        builder: (context, reminderDataState, child) {
          return FutureBuilder(
            // Future Builder for queried Reminder Data
            future: reminderDataState.reminderData,
            builder: (context, AsyncSnapshot<Map<ReminderGroup?, List<Reminder>>?> snapshot) {
              // If Reminder Data is empty, disable the New Reminder button
              if (snapshot.hasData) {
                if(snapshot.data!.isNotEmpty) {
                  return button(true);
                } else {
                  return button(false);
                }
              } else {
                return button(true);
              }
            }
          );
        }
      )
    );
  }
}