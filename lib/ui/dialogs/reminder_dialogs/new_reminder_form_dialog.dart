import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'reminder_form.dart';
import '../../../models/models.dart';
import '../../../utils/domain_layer/reminder_data_state.dart';
import '../../../utils/ui_layer/ui_reminder_group_manager.dart';

class NewReminderFormDialog extends StatelessWidget {
  NewReminderFormDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<FormButtonData> buttonList = [
      FormButtonData(text: 'OK', callback: submitButtonCallback, buttonColour: Color(0xff99FF99), textColour: Colors.black),
    ];
    return SimpleDialog(
      title: Text('New Reminder'),
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        SingleChildScrollView(
          child: ReminderForm(
            buttonList: buttonList,
          ),
        )
      ]
    );
  }

  void submitButtonCallback(context, reminderNameController, reminderGroupID, intervalTextController, intervalType, descriptionController) async {
    final reminder = Reminder(
      id: 0,
      name: reminderNameController.text,
      reminderGroupID: reminderGroupID,
      intervalValue: int.parse(intervalTextController.text),
      intervalType: intervalType,
      nextDate: DateTime.now(), // To calculate new nextDate from now
      description: descriptionController.text,
    );
    Provider.of<ReminderDataState>(context, listen: false).newReminder(await reminder.getNewNextDate());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Added!')));

    // Open Reminder Group (in the UI)
    Provider.of<UIReminderGroupManager>(context, listen: false).openGroupByID(reminderGroupID);
  }
}