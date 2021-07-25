import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';

class ReminderForm extends StatefulWidget {
  final String? initialReminderName;
  final int? initialReminderGroupID;
  final String? initialIntervalText;
  final IntervalType? initialIntervalType;
  final DateTime? initialDate;
  final List<FormButtonData> buttonList; // Empty list by default

  const ReminderForm({ Key? key,
    this.initialReminderName,
    this.initialReminderGroupID,
    this.initialIntervalText,
    this.initialIntervalType,
    this.initialDate,
    this.buttonList = const []
  }) : super(key: key);

  @override
  _ReminderFormState createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  final _formKey = GlobalKey<FormState>();

  // Controls size of form fields
  final hDefaultContentPadding = 12.0; // Default left and right content padding values from api.flutter.dev
  final vContentPaddingDropdown = 7.0; // Vertical dropdown content padding
  final vContentPaddingText = 9.0; // Vertical TextField content padding

  // Reminder Name Text Field
  TextEditingController _reminderNameController = TextEditingController();

  // Reminder Group Dropdown
  int? _reminderGroupDropdownValue;

  // Interval Text Field
  TextEditingController _intervalTextController = TextEditingController();

  // Interval Dropdown
  final _intervalDropdownList = IntervalType.values;

  IntervalType _intervalDropdownValue = IntervalType.weeks; // Default value of 'Weeks'

  
  // Start Date Date Picker
  DateTime startDate = DateTime.now(); // Default to DateTime.now()
  final firstDate = DateTime.now();
  final lastDate = DateTime.now().add(const Duration(days: 730));
  TextEditingController _datePickerController = TextEditingController(); // For display purposes only

  @override
  void initState() {
    super.initState();
    initialiseInitialValues(); // Setting initial, default values
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          nameTextField(_reminderNameController),
          reminderGroupDropdown(),
          intervalSelector(_intervalTextController),
          startDatePicker(_datePickerController),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i = 0; i < widget.buttonList.length; i++)
                Flexible(
                  child: submitFormButton(
                    _reminderNameController,
                    _reminderGroupDropdownValue,
                    _intervalTextController,
                    _intervalDropdownValue,
                    startDate,
                    widget.buttonList[i])
                )
            ]
          )
        ],
      ),
    );
  }

  void initialiseInitialValues() {
    if(widget.initialReminderName != null) {
      _reminderNameController.text = widget.initialReminderName!;
    }

    _reminderGroupDropdownValue = widget.initialReminderGroupID;

    if(widget.initialIntervalText != null) {
      _intervalTextController.text = widget.initialIntervalText!;
    }

    _intervalDropdownValue = widget.initialIntervalType ?? IntervalType.weeks; // Default value of 'Weeks'

    startDate = widget.initialDate ?? DateTime.now(); // Default value of DateTime.now()
    _datePickerController.text = DateFormat('dd/MM/yyyy').format(startDate); // Display initial date
  }

  Widget nameTextField(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: TextFormField(
        key: Key('Reminder Name Text Field'), // For testing
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Name',
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(hDefaultContentPadding, vContentPaddingText, hDefaultContentPadding, vContentPaddingText),
          ),
        validator: (String? value) {
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
            builder: (context, AsyncSnapshot<Map<ReminderGroup?, List<Reminder>>?> snapshot) {
              if (snapshot.hasData) {
                return DropdownButtonFormField(
                  key: Key('Reminder Group Dropdown'), // For testing
                  value: _reminderGroupDropdownValue,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reminder Group',
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(hDefaultContentPadding, vContentPaddingDropdown, hDefaultContentPadding, vContentPaddingDropdown),
                    ),
                  icon: const Icon(Icons.arrow_downward,),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).buttonColor),
                  items: snapshot.data!.keys.map<DropdownMenuItem<int>>((ReminderGroup? group) {
                    return DropdownMenuItem(
                      key: Key(group!.name!), // For testing
                      value: group.id,
                      child: Text(group.name!, style: TextStyle(color: Colors.black),)
                    );
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      _reminderGroupDropdownValue = value;
                    });
                  },
                  validator: (dynamic value) {
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
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(hDefaultContentPadding, vContentPaddingText, hDefaultContentPadding, vContentPaddingText),
                ),
              validator: (String? value) {
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
              value: _intervalDropdownValue,
              icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Theme.of(context).buttonColor),
              items: _intervalDropdownList.map<DropdownMenuItem<IntervalType>>((element) {
                print(describeEnum(element));
                return DropdownMenuItem(
                  key: Key(describeEnum(element)), // For testing
                  value: element,
                  child: Text(element.capitalize(), style: TextStyle(color: Colors.black),)
                );
              }).toList(),
              onChanged: (dynamic value) {
                setState(() {
                  _intervalDropdownValue = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(hDefaultContentPadding, vContentPaddingDropdown, hDefaultContentPadding, vContentPaddingDropdown),
                ),
              validator: (dynamic value) {
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
          final DateTime? picked = await showDatePicker(
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
          labelText: 'Start Date',
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(hDefaultContentPadding, vContentPaddingText, hDefaultContentPadding, vContentPaddingText),
          ),
      )
    );
  }

  Widget submitFormButton(TextEditingController reminderNameController, int? reminderGroupID, TextEditingController intervalTextController, IntervalType? intervalType, DateTime startDate, FormButtonData buttonData) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: TextButton(
        child: Text(buttonData.text), // Button text from FormButtonData
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: buttonData.buttonColour,
          onPrimary: buttonData.textColour,
        ),
        onPressed: () {
          if(_formKey.currentState!.validate()) {
            buttonData.callback!(context, reminderNameController, reminderGroupID, intervalTextController, intervalType, startDate); // Callback from FormButtonData
            Navigator.pop(context);
          }
        },
      )
    );
  }
}

class FormButtonData {
  final String text;
  final Function? callback;
  final Color buttonColour;
  final Color textColour;

  FormButtonData({this.text = 'OK', this.callback, this.buttonColour = const Color(0xff99FF99), this.textColour = Colors.black});
}