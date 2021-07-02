import 'package:flutter/material.dart';

import './new_reminder_group_form_dialog.dart';
import './new_reminder_form_dialog.dart';

class CreateNewNavigationDialog extends StatefulWidget {
  const CreateNewNavigationDialog({ Key key }) : super(key: key);

  @override
  _CreateNewNavigationDialogState createState() => _CreateNewNavigationDialogState();
}

class _CreateNewNavigationDialogState extends State<CreateNewNavigationDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              newReminderGroupFormButton(),
              newReminderFormButton(),
            ],
            ),
          ),
        )
    );
  }

  Widget newReminderGroupFormButton() {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: TextButton(
        child: Text('New Reminder Group'),
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

  Widget newReminderFormButton() {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: TextButton(
        child: Text('New Reminder'),
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