import 'package:flutter/material.dart';
import 'package:phonebook_task_005/main/contacts.dart';
import 'package:phonebook_task_005/processes/sPref.dart';
import 'main/menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonebook Application',
      theme: ThemeData(
        primaryColor: Colors.white,
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 45.0,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionHandleColor: Colors.white,
            selectionColor: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      home: SharedService(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomePage(),
        '/menu': (BuildContext context) => new MainMenu(),
      },
    );
  }
}
