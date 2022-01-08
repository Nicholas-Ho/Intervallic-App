import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intervallic_app/themes.dart';
import 'package:intervallic_app/utils/navigation_manager.dart';

class NavigationDrawer extends StatelessWidget {
  NavigationDrawer({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color foregroundColour = Provider.of<ThemeManager>(context, listen: false).appTheme.drawerSecondaryColour!;
    final Color backgroundColour = Provider.of<ThemeManager>(context, listen: false).appTheme.drawerPrimaryColour!; // 0xffab47bc

    return Drawer(
      child: Material(
        color: backgroundColour,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget> [
              const SizedBox(height: 50),
              drawerTile(context, 'Home', Icons.home, AppPage.intervallicPage, foregroundColour),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(color: foregroundColour),
                      const SizedBox(height: 10),
                      drawerTile(context, 'Settings', Icons.settings, AppPage.settingsPage, foregroundColour),
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

  Widget drawerTile(BuildContext context, String text, IconData icon, AppPage page, Color foregroundColour) {
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