import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/theme_manager.dart';
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
            color: getColour(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(reminder!.name!, style: TextStyle(fontSize: 20, color: getSecondaryColour(context))),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getColour(context) {
    if(reminder!.isOverdue) {
      return Provider.of<ThemeManager>(context, listen: false).appTheme.overduePrimaryColour!;
    } else {
      return Provider.of<ThemeManager>(context, listen: false).appTheme.duePrimaryColour!;
    }
  }

  Color getSecondaryColour(context) {
    if(reminder!.isOverdue) {
      return Provider.of<ThemeManager>(context, listen: false).appTheme.overdueSecondaryColour!;
    } else {
      return Provider.of<ThemeManager>(context, listen: false).appTheme.dueSecondaryColour!;
    }
  }
}