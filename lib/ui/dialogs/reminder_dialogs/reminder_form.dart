import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';

class ReminderForm extends StatefulWidget {
  final String? initialReminderName;
  final int? initialReminderGroupID;
  final int? initialIntervalValue;
  final IntervalType? initialIntervalType;
  final String? initialDescription;
  final List<FormButtonData> buttonList; // Empty list by default

  const ReminderForm({ Key? key,
    this.initialReminderName,
    this.initialReminderGroupID,
    this.initialIntervalValue,
    this.initialIntervalType,
    this.initialDescription,
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

  // Description Text Field
  TextEditingController _descriptionController = TextEditingController();

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
          descriptionTextField(_descriptionController),
          actionButtons(
            _reminderNameController,
            _reminderGroupDropdownValue,
            _intervalTextController,
            _intervalDropdownValue,
            _descriptionController,
            widget.buttonList
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

    if(widget.initialIntervalValue != null) {
      _intervalTextController.text = widget.initialIntervalValue!.toString();
    }

    _intervalDropdownValue = widget.initialIntervalType ?? IntervalType.weeks; // Default value of 'Weeks'

    if(widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
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
                return DropdownMenuItem(
                  key: Key(element.capitalizedSimpleString()), // For testing
                  value: element,
                  child: Text(element.capitalizedSimpleString(), style: TextStyle(color: Colors.black),)
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

  Widget descriptionTextField(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: TextFormField(
        key: Key('Description Text Field'), // For testing
        controller: controller,
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 4,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Description',
          alignLabelWithHint: true,
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(hDefaultContentPadding, vContentPaddingText, hDefaultContentPadding, vContentPaddingText),
          ),
        validator: (String? value) {
          if(value!.length >= 250) {
            return 'Too long.';
          } else {
            return null;
          }
        }
      )
    );
  }

  Widget actionButtons(TextEditingController reminderNameController, int? reminderGroupID, TextEditingController intervalTextController, IntervalType? intervalType, TextEditingController descriptionController, List<FormButtonData> buttonList) {
    final List<Widget> children = [];

    for(int i = 0; i < (buttonList.length * 2 - 1); i++) {
      if(i % 2 == 0) { // Button
        final buttonData = buttonList[i~/2];

        children.add(
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: TextButton(
                child: Text(buttonData.text), // Button text from FormButtonData
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  primary: buttonData.buttonColour,
                  onPrimary: buttonData.textColour,
                ),
                onPressed: () {
                  if(buttonData.requiresValidation == true) {
                    if(_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      buttonData.callback!(context, reminderNameController, reminderGroupID, intervalTextController, intervalType, descriptionController); // Callback from FormButtonData
                    }
                  } else {
                    Navigator.pop(context);
                    buttonData.callback!(context, reminderNameController, reminderGroupID, intervalTextController, intervalType, descriptionController); // Callback from FormButtonData
                  }
                },
              )
            )
          )
        );
      } else { // Divider SizedBox
        children.add(SizedBox(width: 10));
      }
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children
    );
  }
}

class FormButtonData {
  final String text;
  final Function? callback;
  final bool requiresValidation;
  final Color buttonColour;
  final Color textColour;

  FormButtonData({this.text = 'OK', this.callback, this.requiresValidation = true, this.buttonColour = const Color(0xff99FF99), this.textColour = Colors.black});
}