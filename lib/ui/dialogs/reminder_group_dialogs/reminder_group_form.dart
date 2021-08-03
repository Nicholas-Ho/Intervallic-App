import 'package:flutter/material.dart';

class ReminderGroupForm extends StatefulWidget {
  final String? initialReminderName;
  final String? initialDescription;
  final List<FormButtonData> buttonList; // Empty list by default
  const ReminderGroupForm({ Key? key, this.initialReminderName, this.initialDescription, this.buttonList = const [] }) : super(key: key);

  @override
  _ReminderGroupFormState createState() => _ReminderGroupFormState();
}

class _ReminderGroupFormState extends State<ReminderGroupForm> {
  final _formKey = GlobalKey<FormState>();

  // Controls size of form fields
  final hDefaultContentPadding = 12.0; // Default left and right content padding values from api.flutter.dev
  final vContentPaddingDropdown = 7.0; // Vertical dropdown content padding
  final vContentPaddingText = 9.0; // Vertical TextField content padding

  // Reminder Name Text Field
  TextEditingController _reminderGroupNameController = TextEditingController();

  // Description Text Field
  TextEditingController _descriptionController = TextEditingController()
;
  @override
  Widget build(BuildContext context) {
    if(widget.initialReminderName != null) {
      // Setting initial, default value
      _reminderGroupNameController.text = widget.initialReminderName!;

      if(widget.initialDescription != null) {
        _descriptionController.text = widget.initialDescription!;
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          nameTextField(_reminderGroupNameController),
          descriptionTextField(_descriptionController),
          actionButtons(_reminderGroupNameController, _descriptionController, widget.buttonList)
        ],
      ),
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
          labelText: 'Name',
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(hDefaultContentPadding, vContentPaddingText, hDefaultContentPadding, vContentPaddingText),
          ),
        validator: (String? value) {
          if(value == null || value.isEmpty) {
            return 'Reminder Group name cannot be empty';
          } else {
            return null;
          }
        }
      )
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

  Widget actionButtons(TextEditingController reminderGroupNameController, TextEditingController descriptionController, List<FormButtonData> buttonList) {
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
                      buttonData.callback!(context, reminderGroupNameController, descriptionController); // Callback from FormButtonData
                    }
                  } else {
                    Navigator.pop(context);
                    buttonData.callback!(context, reminderGroupNameController, descriptionController); // Callback from FormButtonData
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