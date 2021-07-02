import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import '../models/models.dart';
import '../utils/domain_layer/reminder_data_state.dart';

class NewReminderFormDialog extends StatefulWidget {
  const NewReminderFormDialog({ Key key }) : super(key: key);

  @override
  _NewReminderFormDialogState createState() => _NewReminderFormDialogState();
}

class _NewReminderFormDialogState extends State<NewReminderFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Reminder Name Text Field
  TextEditingController _reminderNameController = TextEditingController();

  // Reminder Group Dropdown
  var reminderGroupDropdownValue;

  // Interval Text Field
  TextEditingController _intervalTextController = TextEditingController();

  // Interval Dropdown
  final intervalDropdownList = ['Days', 'Weeks', 'Months', 'Years'];

  var intervalDropdownValue = 'Weeks'; // Default value of 'Weeks'

  
  // Start Date Date Picker
  var startDate = DateTime.now(); // Default to DateTime.now()
  final firstDate = DateTime.now();
  final lastDate = DateTime.now().add(const Duration(days: 365));
  TextEditingController _datePickerController = TextEditingController(); // For display purposes only

  @override
  Widget build(BuildContext context) {
    _datePickerController.text = DateFormat('dd/MM/yyyy').format(startDate); // Default to DateTime.now()
    return AlertDialog(
      title: Text('New Reminder'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              nameTextField(_reminderNameController),
              reminderGroupDropdown(),
              intervalSelector(_intervalTextController),
              startDatePicker(_datePickerController),
              createReminderButton(
                _reminderNameController,
                reminderGroupDropdownValue,
                _intervalTextController,
                intervalDropdownValue,
                startDate
              ),
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
        key: Key('Reminder Name Text Field'), // For testing
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Name'
          ),
        validator: (String value) {
          if(value == null || value.isEmpty) {
            return 'Reminder name cannot be empty';
          } else {
            return null;
          }
        }
      )
    );
  }

  Widget reminderGroupDropdown() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Consumer<ReminderDataState>( // Reminder Group Dropdown list. Requires Consumer for Reminder Data
        builder: (context, reminderDataState, child) {
          return FutureBuilder(
            // Future Builder for queried Reminder Data
            future: reminderDataState.reminderData,
            builder: (context, AsyncSnapshot<Map<ReminderGroup, List<Reminder>>> snapshot) {
              if (snapshot.hasData) {
                return DropdownButtonFormField(
                  key: Key('Reminder Group Dropdown'), // For testing
                  value: reminderGroupDropdownValue,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reminder Group'
                    ),
                  icon: const Icon(Icons.arrow_downward,),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).buttonColor),
                  items: snapshot.data.keys.map<DropdownMenuItem<int>>((ReminderGroup group) {
                    return DropdownMenuItem(
                      key: Key(group.name), // For testing
                      value: group.id,
                      child: Text(group.name, style: TextStyle(color: Colors.black),)
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      reminderGroupDropdownValue = value;
                    });
                  },
                  validator: (value) {
                    if(value == null) {
                      return 'Reminder Group cannot be empty';
                    } else {
                      return null;
                    }
                  },
                );
              } else {
                return Text('Loading Reminder Groups');
              }
            }
          );
        }
      )
    );
  }

  Widget intervalSelector(TextEditingController controller) {
    final defaultContentPadding = 12.0; // Default left and right content padding values from api.flutter.dev
    final contentPaddingDropdown = 16.0; // Dropdown content padding
    final contentPaddingText = contentPaddingDropdown + 3.0; // TextField content padding
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextFormField(
              key: Key('Interval Selector Text Field'), // For testing
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Interval',
                contentPadding: EdgeInsets.fromLTRB(defaultContentPadding, contentPaddingText, defaultContentPadding, contentPaddingText),
                ),
              validator: (String value) {
                if(value == null || value.isEmpty){
                  return 'Interval length cannot be empty';
                } else {
                  try {
                    int.parse(value); // Check if value is integer
                    return null;
                  } on FormatException {
                    return 'Interval length must be an integer!';
                  }
                }
              }
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField(
              key: Key('Interval Selector Dropdown'), // For testing
              value: intervalDropdownValue,
              icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Theme.of(context).buttonColor),
              items: intervalDropdownList.map<DropdownMenuItem<String>>((element) {
                return DropdownMenuItem(
                  key: Key(element), // For testing
                  value: element,
                  child: Text(element, style: TextStyle(color: Colors.black),)
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  intervalDropdownValue = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // labelText: 'Interval',
                contentPadding: EdgeInsets.fromLTRB(defaultContentPadding, contentPaddingDropdown, defaultContentPadding, contentPaddingDropdown),
                ),
              validator: (value) {
                if(value == null) {
                  return 'Interval length cannot be empty';
                } else {
                  return null;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget startDatePicker(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: TextFormField(
        key: Key('Date Picker Text Field'), // For testing
        controller: controller,
        onTap: () async {
          FocusScope.of(context).requestFocus(new FocusNode()); // Stops keyboard from appearing

          // Show Date Picker
          final DateTime picked = await showDatePicker(
            context: context,
            initialDate: startDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );

          if(picked != null && picked != startDate) {
            setState(() {
              startDate = picked;
              });
          }

          controller.text = DateFormat('dd/MM/yyyy').format(startDate); // Update Text Field
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Start Date'
          ),
      )
    );
  }

  Widget createReminderButton(TextEditingController reminderNameController, int reminderGroupID, TextEditingController intervalTextController, String intervalType, DateTime startDate) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: TextButton(
        child: Text('Add'),
        onPressed: () {
          if(_formKey.currentState.validate()) {
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
            Navigator.pop(context);
          }
        },
      )
    );
  }
}