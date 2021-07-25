import 'package:flutter/material.dart';

class ReminderGroupForm extends StatefulWidget {
  final String? initialReminderName;
  final List<FormButtonData> buttonList; // Empty list by default
  const ReminderGroupForm({ Key? key, this.initialReminderName, this.buttonList = const [] }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    if(widget.initialReminderName != null) {
      _reminderGroupNameController.text = widget.initialReminderName!; // Setting initial, default value
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          nameTextField(_reminderGroupNameController),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i = 0; i < widget.buttonList.length; i++)
                Flexible(
                  child: submitFormButton(_reminderGroupNameController, widget.buttonList[i])
                )
            ]
          )
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

  Widget submitFormButton(TextEditingController reminderGroupNameController, FormButtonData buttonData) {
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
            buttonData.callback!(context, reminderGroupNameController); // Callback from FormButtonData
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