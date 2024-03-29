import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'reminder_group_form.dart';
import '../../../models/models.dart';
import '../../../utils/domain_layer/reminder_data_state.dart';
import '../../../utils/ui_layer/ui_reminder_group_manager.dart';

class NewReminderGroupFormDialog extends StatelessWidget {
  NewReminderGroupFormDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<FormButtonData> buttonList = [
      FormButtonData(text: 'OK', callback: submitButtonCallback, buttonColour: Color(0xff99FF99), textColour: Colors.black),
    ];
    return AlertDialog(
      title: Text('New Group'),
      content: SingleChildScrollView(
        child: ReminderGroupForm(
          buttonList: buttonList,
        ),
        )
    );
  }

  void submitButtonCallback(context, reminderGroupNameController, descriptionController) {
    Provider.of<ReminderDataState>(context, listen: false).newReminderGroup(
      ReminderGroup(
        id: 0,
        name: reminderGroupNameController.text,
        description: descriptionController.text,
      )
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Group Created!')));

    // Close all Reminder Groups (in the UI)
    Provider.of<UIReminderGroupManager>(context, listen: false).closeAll();
  }
}