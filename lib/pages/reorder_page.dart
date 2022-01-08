import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes.dart';
import '../ui/reminder_list/reminder_list_reorderable.dart';

class ReorderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColour = Provider.of<ThemeManager>(context, listen: false).appTheme.reorderBackgroundColour!;

    return Scaffold(
      backgroundColor: backgroundColour,
      appBar: AppBar(
        backgroundColor: backgroundColour,
        elevation: 0,
        centerTitle: true,
        title: Text("Intervallic", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
        leading: CancelReorderButton(),
        actions: [EndReorderButton()],
      ),
      body: ReminderListReorderable(), // Wrapped to switch between the Reminder List and Reorderable List
      floatingActionButton: null
    );
  }
}
