import 'package:flutter/material.dart';

class EmptyReminderListPlaceholder extends StatelessWidget {
  const EmptyReminderListPlaceholder({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event,
              size: MediaQuery.of(context).size.width * 0.4,
              color: Theme.of(context).primaryColorLight),
          SizedBox(height: 10,),
          Text('Nothing to see here!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColorLight)),
          SizedBox(height: 10,),
          Text('Add a Reminder Group to get started.',
              style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColorLight))
        ],
      )
    );
  }
}