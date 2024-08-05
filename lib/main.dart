import 'package:dirty_roots/home.dart';
import 'package:dirty_roots/notifications/firebase_notifications.dart';
import 'package:dirty_roots/postDetail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'themeNotifier.dart';

import 'notifications/firebase_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'home.dart';
import 'posts.dart';
import 'map.dart';
import 'calendar.dart';
import 'forum.dart';
import 'settings.dart';
import 'postDetail.dart';
import 'eventDetail.dart';  

import 'api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(PostAdapter());
  await Hive.openBox<Post>('posts');

  Hive.registerAdapter(EventAdapter());
  await Hive.openBox<Event>('events');


  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeNotifier(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  void _initilizeNofications(BuildContext context, GlobalKey<NavigatorState> navigatorKey) async {

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        // Retrieve post from Hive box
        Box<Post> postsBox = Hive.box<Post>('posts');
        Post post = postsBox.get(payload)!;
        
        // Navigate to PostDetailPage
        navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (context) => PostDetailPage(
            post: post,
          ),
        ));
      }
    });
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter Demo',
        
        // themeMode: Provider.of<ThemeNotifier>(context).themeMode,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.belleza(
              fontSize: 30.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Color(0xFF049391).withOpacity(0.75),
            // add a little shadow to the app bar
            shadowColor: Colors.black,
            elevation: 5.0,
            // make system overlay color white
            systemOverlayStyle: SystemUiOverlayStyle(
              // make this a bit darker than the app bar color
              statusBarColor: Color(0xFF049391)
            ),
          ),
          // change color of selected tab
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFF049391).withOpacity(0.75),
          ),
          // make app bar color green and create a color scheme
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF049391),
            onPrimary: Color(0xFF049391),
            secondary: Colors.green,
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
            background: Colors.white,
            onBackground: Colors.black,
          ),

          textTheme: TextTheme(
            bodyMedium:
                GoogleFonts.sourceSansPro(fontSize: 16.0, color: Colors.black),
            // for title large assign font Minerva Modern
            titleMedium: GoogleFonts.belleza(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              // fontFamily: 'Minerva Modern',
            ),
          ),
        ),

        // darkTheme: ThemeData(
        //   appBarTheme: AppBarTheme(
        //     titleTextStyle: GoogleFonts.belleza(
        //       fontSize: 30.0,
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   colorScheme: const ColorScheme.dark(
        //       primary: Colors.green,
        //       onPrimary: Color(0xFF049391),
        //       secondary: Colors.green,
        //       onSecondary: Colors.white,
        //       surface: Colors.black,
        //       onSurface: Colors.white,
        //       background: Colors.black,
        //       onBackground: Colors.white,
        //       ),
        //   // dark theme
          
        //   textTheme: TextTheme(
        //     bodyMedium:
        //         GoogleFonts.sourceSansPro(fontSize: 16.0, color: Colors.white),
        //     // for title large assign font Minerva Modern
        //     titleMedium: GoogleFonts.belleza(
        //       fontSize: 20.0,
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //       // fontFamily: 'Minerva Modern',
        //     ),
        //   ),
        // ),
        home: const MyHomePage(title: 'DIRTY ROOTS'),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          _initilizeNofications(context, navigatorKey);
          return child!;
        });
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initState() {
    super.initState();
    _scheduleBlogPostCheck();
  }

  Future<void> _scheduleBlogPostCheck() async {
    // Periodically check for new blog posts
    const interval = Duration(hours: 1); // Check every hour
    Timer.periodic(interval, (timer) async {
      await _checkForNewBlogPosts();
    });
  }

  Future<void> _checkForNewBlogPosts() async {
    // Fetch blog posts from the API
    final posts = await fetchPosts();
    final postsBox = Hive.box<Post>('posts');
    await _showNotification(posts[0]);
    // for (Post post in posts) {
    //   if (!postsBox.containsKey(post.id)) {
    //     postsBox.put(post.id, post);
    //     await _showNotification(post);
    //   }
    // }
  }

  Future<void> _showNotification(Post post) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'blog_post_channel',
      'Blog Post Notifications',
      'Notifications for new blog posts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      post.title,
      'New blog post available',
      platformChannelSpecifics,
      payload: post.id,
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    Home(),
    Posts(),
    Calendar(),
    Map(),
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
      appBar: _selectedIndex < 3 ? AppBar(
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
      ): null,
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'forum',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF049391),
        unselectedLabelStyle: GoogleFonts.belleza(fontSize: 12.0),
        selectedLabelStyle: GoogleFonts.belleza(fontSize: 12.0),
        onTap: _onItemTapped,
      ),
    );
  }
}
