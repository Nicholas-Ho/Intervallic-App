import 'package:flutter/material.dart';

import 'package:intervallic_app/models/models.dart';

class ReminderGroupDetailsDialog extends StatelessWidget {
  const ReminderGroupDetailsDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Reminder Group Details!'),
    );
  }
}