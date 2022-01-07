import 'package:flutter/material.dart';

import '../ui/navigation_drawer.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColour = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColour,
      drawer: NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: backgroundColour,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Text("Settings", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Container(),
    );
  }
}