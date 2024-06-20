import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'themeNotifier.dart'; // Import your ThemeNotifier

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the theme notifier using Provider
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: SwitchListTile(
          title: const Text('Dark Mode'),
          value: isDarkMode,
          onChanged: (bool value) {
            // Toggle the theme mode
            themeNotifier.toggleTheme();
          },
        ),
      ),
    );
  }
}