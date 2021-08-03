import 'package:flutter/material.dart';

import 'package:intervallic_app/models/models.dart';
import 'update_reminder_group_form_dialog.dart';

class ReminderGroupDetailsDialog extends StatelessWidget {
  const ReminderGroupDetailsDialog({ this.reminderGroup, Key? key }) : super(key: key);
  final ReminderGroup? reminderGroup;

  List<Widget> generateDetailsView(BuildContext context) {
    final descriptionColour = reminderGroup!.description != null ? Colors.black : Theme.of(context).disabledColor;

    final list = [
      getExpandedRow(
        Text('Name:', style: TextStyle(fontWeight: FontWeight.w700)),
        Text(reminderGroup!.name!),
      ),
      getExpandedRow(
        Text('Description:', style: TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
        Container(),
      ),
      Padding( // Description
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
          width: double.infinity,
          child: Text(
            reminderGroup!.description ?? 'No Description',
            style: TextStyle(color: descriptionColour),
            textAlign: TextAlign.left,
          ),
        ),
      ),
      buttons(context)
    ];

    return list;
  }

  Widget buttons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(0.0),
          child: TextButton(
            child: Text('Edit'),
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: Color(0xffffcc66), // Orange
              onPrimary: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return UpdateReminderGroupFormDialog(reminderGroup: reminderGroup,);
                }
              );
            },
          )
        )
      ]
    );
  }

  Widget getExpandedRow(Widget widget1, Widget widget2) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Expanded(
            child: widget1,
            flex: 1
          ),
          Expanded(
            child: widget2,
            flex: 2
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: generateDetailsView(context),
          ),
        ),
      ]
    );
  }
}