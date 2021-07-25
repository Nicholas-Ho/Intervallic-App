import 'package:flutter/material.dart';

import 'package:intervallic_app/models/models.dart';

class ReminderDetailsDialog extends StatelessWidget {
  const ReminderDetailsDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Reminder Details!'),
    );
  }
}