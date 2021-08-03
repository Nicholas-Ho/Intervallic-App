import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/utils/domain_layer/reminder_data_state.dart';
import 'update_reminder_form_dialog.dart';

class ReminderDetailsDialog extends StatelessWidget {
  const ReminderDetailsDialog({ this.reminder, Key? key }) : super(key: key);
  final Reminder? reminder;

  List<Widget> generateDetailsView(BuildContext context) {
    final descriptionColour = reminder!.description != null ? Colors.black : Theme.of(context).disabledColor;

    // Generating the display string for the interval
    String intervalString = reminder!.intervalValue!.toString()+ ' ' + reminder!.intervalType!.capitalizedSimpleString();
    if(reminder!.intervalValue! == 1) {
      // Preventing "1 Days" grammatical error
      intervalString = intervalString.substring(0, intervalString.length - 1);
    }

    // Generating the display string for the date
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    String dateString = reminder!.nextDate!.day.toString() + ' ' + months[reminder!.nextDate!.month - 1] + ' ' + reminder!.nextDate!.year.toString();

    final list = [
      getExpandedRow(
        Text('Name:', style: TextStyle(fontWeight: FontWeight.w700)),
        Text(reminder!.name!),
      ),
      getExpandedRow(
        Text('Group:', style: TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
        reminderGroupNameText(),
      ),
      getExpandedRow(
        Text('Interval:', style: TextStyle(fontWeight: FontWeight.w700)),
        Text(intervalString),
      ),
      getExpandedRow(
        Text('Next Due:', style: TextStyle(fontWeight: FontWeight.w700)),
        Text(dateString),
      ),
      getExpandedRow(
        Text('Description:', style: TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
        Container(),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
          width: double.infinity,
          child: Text(
            reminder!.description ?? 'No Description',
            style: TextStyle(color: descriptionColour),
            textAlign: TextAlign.left,
          ),
        ),
      ),
      buttons(context),
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
                  return UpdateReminderFormDialog(reminder: reminder,);
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

  Widget reminderGroupNameText() {
    return Consumer<ReminderDataState>( // Requires Consumer for Reminder Data
      builder: (context, reminderDataState, child) {
        return FutureBuilder(
          // Future Builder for queried Reminder Data
          future: reminderDataState.reminderData,
          builder: (context, AsyncSnapshot<Map<ReminderGroup?, List<Reminder>>?> snapshot) {
            if (snapshot.hasData) {
              try {
                final reminderGroup = snapshot.data!.keys.firstWhere((group) => group!.id == reminder!.reminderGroupID!);
                return Text(reminderGroup!.name!);
              } on StateError {
                print('Error - Reminder Group with ID ${reminder!.reminderGroupID} not found.');
                return Text('Error - Reminder Group with ID ${reminder!.reminderGroupID} not found.');
              }
            } else {
              return Text('Loading Reminder Group name');
            }
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: generateDetailsView(context),
          ),
        ),
      ]
    );
  }
}