import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intervallic_app/models/models.dart';
import 'package:intervallic_app/ui/dialogs/reminder_group_dialogs/reminder_group_details_dialog.dart';
import 'package:intervallic_app/utils/ui_layer/ui_reminder_group_manager.dart';

// Tile for Reminder Group
class ReminderGroupTile extends StatelessWidget {
  final ReminderGroup? reminderGroup;
  final List<Reminder>? reminders;

  final double circleRadius = 25;

  ReminderGroupTile({this.reminderGroup, this.reminders});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        height: 60,
        child: GestureDetector(
          onTap: () {
            final bool isAlreadyOpen = Provider.of<UIReminderGroupManager>(context, listen: false).checkOpenGroup(reminderGroup!);
            // If the Reminder Group is closed, open it. If it is already open, close it.
            if(isAlreadyOpen == false) {
              Provider.of<UIReminderGroupManager>(context, listen: false).openGroup(reminderGroup!);
            } else {
              Provider.of<UIReminderGroupManager>(context, listen: false).closeAll();
            }
          },
          onLongPress: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return ReminderGroupDetailsDialog(reminderGroup: reminderGroup);
              }
            );
          },
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(reminderGroup!.name!, style: TextStyle(fontSize: 20)),
                  ),
                  overdueIndicator(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ExpandArrow(reminderGroup: reminderGroup)
                  )
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Red circle indicating overdue reminders in the Group
  Widget overdueIndicator() {
    int overdueCount = 0;
    reminders!.forEach((reminder) {
      if(reminder.isOverdue) {
        overdueCount++;
      }
    });
    if(overdueCount > 0){
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          height: circleRadius,
          width: circleRadius,
          child: Container(
            decoration: BoxDecoration(color: Color(0xffec1c24), shape: BoxShape.circle),
            child: Center(
              child: Text(overdueCount.toString(), style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),)
            )
          )
        )
      );
    } else {
      return Container();
    }
  }
}

// Rotating arrow icon to show if the Group is open
class ExpandArrow extends StatefulWidget {
  const ExpandArrow({ this.reminderGroup, Key? key }) : super(key: key);

  final ReminderGroup? reminderGroup;

  @override
  _ExpandArrowState createState() => _ExpandArrowState();
}

class _ExpandArrowState extends State<ExpandArrow> with TickerProviderStateMixin {
  AnimationController? _rotationController;
  Animation<double>? _rotationAnimation;
  bool isOpen = false;

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      upperBound: 1.0,
    );
    _rotationAnimation = CurvedAnimation(
      curve: Curves.linear,
      parent: Tween(begin: 0.0, end: 0.25).animate(_rotationController!),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(ExpandArrow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(isOpen == false && shouldBeOpen() == true) {
      _rotationController!.forward(from: 0);
      isOpen = true;
    } else if(isOpen == true && shouldBeOpen() == false) {
      _rotationController!.animateBack(0);
      isOpen = false;
    }
  }

  @override
  void dispose() {
    _rotationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationAnimation!,
      child: Icon(Icons.chevron_right)
    );
  }

  bool shouldBeOpen() {
    return Provider.of<UIReminderGroupManager>(context, listen: false).checkOpenGroup(widget.reminderGroup!);
  }
}