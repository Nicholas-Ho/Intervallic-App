import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'reminder_form.dart';
import '../../../models/models.dart';
import '../../../utils/domain_layer/reminder_data_state.dart';

class UpdateReminderFormDialog extends StatelessWidget {
  UpdateReminderFormDialog({ this.reminder, Key? key }) : super(key: key);

  final Reminder? reminder;

  @override
  Widget build(BuildContext context) {
    final List<FormButtonData> buttonList = [
      FormButtonData(text: 'Update', callback: submitButtonCallback, buttonColour: Color(0xff99FF99), textColour: Colors.black),
      FormButtonData(text: 'Delete', callback: deleteButtonCallback,requiresValidation: false, buttonColour: Color(0xffec1c24), textColour: Colors.white),
    ];
    return SimpleDialog(
      title: Text('Update Group'),
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        SingleChildScrollView(
          child: ReminderForm(
            initialReminderName: reminder!.name,
            initialReminderGroupID: reminder!.reminderGroupID,
            initialIntervalValue: reminder!.intervalValue,
            initialIntervalType: reminder!.intervalType,
            initialDescription: reminder!.description,
            buttonList: buttonList,
          ),
        )
      ]
    );
  }

  void submitButtonCallback(context, reminderNameController, reminderGroupID, intervalTextController, intervalType, descriptionController) {
    final intervalValue = int.parse(intervalTextController.text);

    if(intervalValue == reminder!.intervalValue && intervalType == reminder!.intervalType) {
      Provider.of<ReminderDataState>(context, listen: false).updateReminder(
        Reminder(
          id: reminder!.id!,
          name: reminderNameController.text,
          reminderGroupID: reminderGroupID,
          intervalValue: int.parse(intervalTextController.text),
          intervalType: intervalType,
          nextDate: reminder!.nextDate,
          description: descriptionController.text,
        )
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Updated!')));
    } else {
      // If the interval of the Reminder changed, ask if the user wants to update the due date
      showDialog(
        context: context,
        barrierDismissible: false, // They MUST respond
        builder: (context) {
          return UpdateReminderDialog(
            id: reminder!.id!,
            name: reminderNameController.text,
            reminderGroupID: reminderGroupID,
            intervalValue: intervalValue,
            intervalType: intervalType,
            nextDate: reminder!.nextDate,
            description: descriptionController.text,
          );
        }
      );
    }
  }

  void deleteButtonCallback(context, _, __, ___, ____, _____) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DeleteReminderDialog(reminder: reminder,);
      }
    );
  }
}

class UpdateReminderDialog extends StatelessWidget {
  const UpdateReminderDialog({
    this.id,
    this.name,
    this.reminderGroupID,
    this.intervalValue,
    this.intervalType,
    this.nextDate,
    this.description,
    Key ? key
  }) : super(key: key);

  final int? id;
  final String? name;
  final int? reminderGroupID;
  final int? intervalValue;
  final IntervalType? intervalType;
  final DateTime? nextDate;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Update Group'),
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'The interval of this Reminder was changed. Do you want to reset the due date?',
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: buttons(context),
              ),
            ],
          )
        )
      ]
    );
  }

  Widget buttons(context) {
    final children = [
      Flexible(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: TextButton(
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: Color(0xff99FF99),
              onPrimary: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              final updatedReminder = Reminder(
                id: id,
                name: name,
                reminderGroupID: reminderGroupID,
                intervalValue: intervalValue,
                intervalType: intervalType,
                nextDate: DateTime.now(), // Recalculate nextDate from now
                description: description,
              );
              Provider.of<ReminderDataState>(context, listen: false).updateReminder(updatedReminder.getNewNextDate());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Updated! Due date changed.')));
            },
          )
        )
      ),
      SizedBox(width: 10), // Sized Box divider
      Flexible(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: TextButton(
            child: Text('Skip'),
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: Color(0xffec1c24),
              onPrimary: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              final updatedReminder = Reminder(
                id: id,
                name: name,
                reminderGroupID: reminderGroupID,
                intervalValue: intervalValue,
                intervalType: intervalType,
                nextDate: nextDate, // If not, keep the original nextDate
                description: description,
              );
              Provider.of<ReminderDataState>(context, listen: false).updateReminder(updatedReminder.getNewNextDate());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Updated! Due date not changed.')));
            },
          )
        )
      )
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children
    );
  }
}

class DeleteReminderDialog extends StatelessWidget {
  const DeleteReminderDialog({ this.reminder, Key ? key }) : super(key: key);
  final Reminder? reminder;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Warning'),
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Are you sure you want to delete this Reminder?',
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: buttons(context),
              ),
            ],
          )
        )
      ]
    );
  }

  Widget buttons(context) {
    final children = [
      Flexible(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: TextButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: Color(0xffec1c24),
              onPrimary: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ReminderDataState>(context, listen: false).deleteReminder(reminder!);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Deleted!')));
            },
          )
        )
      ),
      SizedBox(width: 10), // Sized Box divider
      Flexible(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: TextButton(
            child: Text('Cancel'),
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: Color(0xffffcc66),
              onPrimary: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        )
      )
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children
    );
  }
}