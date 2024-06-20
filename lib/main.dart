import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'themeNotifier.dart';

import 'posts.dart';
import 'map.dart';
import 'calendar.dart';
import 'forum.dart';
import 'settings.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeNotifier(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: Provider.of<ThemeNotifier>(context).themeMode,
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          onPrimary: Color(0xFF049391),
          secondary: Colors.green,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          background: Colors.white,
          onBackground: Colors.black,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black),

        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          onPrimary: Colors.black,
          secondary: Colors.green,
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          background: Colors.black,
          onBackground: Colors.white,
        ),
      ),
      home: const MyHomePage(title: 'Dirty Roots Berlin'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Add this line

  // Define your tabs content here. For simplicity, we're using Text widgets.
  // Replace these with your actual widgets for each tab.
  static final List<Widget> _widgetOptions = <Widget>[
    Posts(),
    Map(),
    Calendar(),
    Forum(),
  ];

  void _onItemTapped(int index) {
    // Add this method
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // add icon to the left of the app bar from assets
        leading: Image.asset('assets/icon2.png'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.compost),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
