import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonebook_task_005/main/contacts.dart';
import 'package:phonebook_task_005/main/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedService extends StatefulWidget {
  const SharedService({Key? key}) : super(key: key);

  @override
  _SharedServiceState createState() => _SharedServiceState();
}

class _SharedServiceState extends State<SharedService> {
  late String finalEmail = '';

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedData = sharedPreferences.getString('data');
    setState(() {
      if (obtainedData != null) {
        finalEmail = obtainedData;
      }
    });
  }

  @override
  void initState() {
    getValidationData().whenComplete(() async {
      Timer(
          Duration(seconds: 1),
          () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      finalEmail.isEmpty ? MainMenu() : HomePage()),
              (_) => false));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
