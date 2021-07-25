import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'reminder_form.dart';
import '../../../models/models.dart';
import '../../../utils/domain_layer/reminder_data_state.dart';

class NewReminderFormDialog extends StatelessWidget {
  NewReminderFormDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<FormButtonData> buttonList = [
      FormButtonData(text: 'OK', callback: submitButtonCallback, buttonColour: Color(0xff99FF99), textColour: Colors.black),
    ];
    return AlertDialog(
      title: Text('New Reminder'),
      content: SingleChildScrollView(
        child: ReminderForm(
          buttonList: buttonList,
        ),
        )
    );
  }

  void submitButtonCallback(context, reminderNameController, reminderGroupID, intervalTextController, intervalType, startDate) {
    Provider.of<ReminderDataState>(context, listen: false).newReminder(
      Reminder(
        id: 0,
        name: reminderNameController.text,
        reminderGroupID: reminderGroupID,
        intervalValue: int.parse(intervalTextController.text),
        intervalType: intervalType,
        nextDate: startDate,
      )
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Added!')));
  }
}