import 'package:flutter/material.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/ui/dialogs/reminder_dialogs/reminder_details_dialog.dart';
// Tile for Reminder
class ReminderTile extends StatelessWidget {
  final Reminder? reminder;

  ReminderTile({this.reminder});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
      child: SizedBox(
        height: 60,
        child: GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return ReminderDetailsDialog(reminder: reminder);
              }
            );
          },
          child: Card(
            color: getColour(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(reminder!.name!, style: TextStyle(fontSize: 20, color: getSecondaryColour())),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getColour() {
    if(reminder!.isOverdue) {
      return Color(0xffec1c24);
    } else {
      return Color(0xff99FF99);
    }
  }

  Color getSecondaryColour() {
    if(getColour() == Color(0xffec1c24)) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}