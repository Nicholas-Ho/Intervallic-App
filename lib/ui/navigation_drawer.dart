import 'package:flutter/material.dart';

import 'package:intervallic_app/utils/navigation_manager.dart';

class NavigationDrawer extends StatelessWidget {
  NavigationDrawer({ Key? key }) : super(key: key);

  final Color foregroundColour = Colors.white;
  final Color backgroundColour = Color(0xffab47bc);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: backgroundColour,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget> [
              const SizedBox(height: 50),
              drawerTile(context, 'Home', Icons.home, AppPage.intervallicPage),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(color: foregroundColour),
                      const SizedBox(height: 10),
                      drawerTile(context, 'Settings', Icons.settings, AppPage.settingsPage),
                      const SizedBox(height: 20),
                    ]
                  )
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerTile(BuildContext context, String text, IconData icon, AppPage page) {
    final Color hoverColour = Colors.white70;
    return ListTile(
      leading: Icon(icon, color: foregroundColour),
      title: Text(text, style: TextStyle(color: foregroundColour)),
      hoverColor: hoverColour,
      onTap: () {
        Navigator.of(context).pop();
        NavigationManager().changePage(page, drawerContext: context);
      },
    );
  }
}