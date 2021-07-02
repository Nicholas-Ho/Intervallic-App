import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/models.dart';
import '../utils/domain_layer/reminder_data_state.dart';

class NewReminderGroupFormDialog extends StatefulWidget {
  const NewReminderGroupFormDialog({ Key key }) : super(key: key);

  @override
  _NewReminderGroupFormDialogState createState() => _NewReminderGroupFormDialogState();
}

class _NewReminderGroupFormDialogState extends State<NewReminderGroupFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Reminder Name Text Field
  TextEditingController _reminderGroupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Reminder Group'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              nameTextField(_reminderGroupNameController),
              createReminderGroupButton(_reminderGroupNameController,),
            ],
            ),
          ),
        )
    );
  }

  Widget nameTextField(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: TextFormField(
        key: Key('Reminder Group Name Text Field'), // For testing
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Name'
          ),
        validator: (String value) {
          if(value == null || value.isEmpty) {
            return 'Reminder Group name cannot be empty';
          } else {
            return null;
          }
        }
      )
    );
  }

  Widget createReminderGroupButton(TextEditingController reminderGroupNameController) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: TextButton(
        child: Text('Add'),
        onPressed: () {
          if(_formKey.currentState.validate()) {
            Provider.of<ReminderDataState>(context, listen: false).newReminderGroup(
              ReminderGroup(
                id: 0,
                name: reminderGroupNameController.text,
              )
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder Group Created!')));
            Navigator.pop(context);
          }
        },
      )
    );
  }
}