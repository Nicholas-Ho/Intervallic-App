import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'reminder_group_form.dart';
import '../../../models/models.dart';
import '../../../utils/domain_layer/reminder_data_state.dart';

class UpdateReminderGroupFormDialog extends StatelessWidget {
  UpdateReminderGroupFormDialog({ this.reminderGroup, Key? key }) : super(key: key);

  final ReminderGroup? reminderGroup;

  @override
  Widget build(BuildContext context) {
    final List<FormButtonData> buttonList = [
      FormButtonData(text: 'Update', callback: submitButtonCallback, buttonColour: Color(0xff99FF99), textColour: Colors.black),
      FormButtonData(text: 'Delete', callback: deleteButtonCallback, requiresValidation: false, buttonColour: Color(0xffec1c24), textColour: Colors.white),
    ];
    return SimpleDialog(
      title: Text('Update Group'),
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        SingleChildScrollView(
          child: ReminderGroupForm(
            initialReminderName: reminderGroup!.name,
            initialDescription: reminderGroup!.description,
            buttonList: buttonList,
          ),
        )
      ]
    );
  }

  void submitButtonCallback(context, reminderGroupNameController, descriptionController) {
    Provider.of<ReminderDataState>(context, listen: false).updateReminderGroup(
      ReminderGroup(
        id: reminderGroup!.id!,
        name: reminderGroupNameController.text,
        description: descriptionController.text,
      )
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Group Updated!')));
  }

  void deleteButtonCallback(context, _, __) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DeleteReminderGroupDialog(reminderGroup: reminderGroup,);
      }
    );
  }
}

class DeleteReminderGroupDialog extends StatelessWidget {
  const DeleteReminderGroupDialog({ this.reminderGroup, Key ? key }) : super(key: key);
  final ReminderGroup? reminderGroup;

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
                      'Deleting the Group will delete all Reminders in the Group. Do you want to continue?',
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
              Provider.of<ReminderDataState>(context, listen: false).deleteReminderGroup(reminderGroup!);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Group Deleted!')));
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