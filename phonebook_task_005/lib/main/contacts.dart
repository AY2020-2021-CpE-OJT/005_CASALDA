import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:phonebook_task_005/addContacts/create.dart';
import 'package:phonebook_task_005/update/contactUpdate.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String authKey = '';
  var authHeaders;
  var loggedUser;

  Future getAuthKeyData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var authKeyObtained = sharedPreferences.getString('authKey');
    loggedUser = sharedPreferences.getString('loggedUser');
    setState(
      () {
        if (authKeyObtained != null) {
          authKey = authKeyObtained;
          authHeaders = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'auth-token': authKey.toString(),
          };
          fetchContacts(authHeaders);
        }
      },
    );
  }

  final String apiUrlget = "https://kc-api-005.herokuapp.com/api/posts";

  List<dynamic> _users = [];

  void fetchContacts(var authHeaders) async {
    print(authKey);
    var result = await http.get(Uri.parse(apiUrlget), headers: authHeaders);
    setState(() {
      _users = jsonDecode(result.body);
    });
  }

  //display name and number

  String _name(dynamic user) {
    return user['first_name'] + " " + user['last_name'];
  }

  String _phonenum(dynamic user) {
    return "Contact # " + user['phone_numbers'][0];
  }

  Future<http.Response> deleteContact(String id) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var authKeyObtained = sharedPreferences.getString('authKey');
    return http.delete(
      Uri.parse('https://kc-api-005.herokuapp.com/api/posts/delete/' + id),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'auth-token': authKeyObtained.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressed;
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final maxDuration = Duration(seconds: 1);
        final isWarning =
            lastPressed == null || now.difference(lastPressed!) > maxDuration;
        if (isWarning) {
          lastPressed = DateTime.now();
          return false;
        } else {
          Fluttertoast.cancel();
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF6EDE7),
        appBar: AppBar(
          centerTitle: true,
          title: Text("Contact List", style: TextStyle(color: Colors.black)),
        ),
        body: FutureBuilder<List<dynamic>>(
          builder: (context, snapshot) {
            return _users.length != 0
                ? RefreshIndicator(
                    color: Colors.black,
                    child: ListView.builder(
                        padding: EdgeInsets.all(12.0),
                        itemCount: _users.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Dismissible(
                            key: Key(_users[index].toString()),
                            onDismissed: (direction) {
                              String id = _users[index]['_id'].toString();
                              String userDeleted =
                                  _users[index]['first_name'].toString();
                              deleteContact(id);
                              print("Status [Deleted]: [" + id + "]");
                              setState(() {
                                _users.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$userDeleted erased from contacts',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                            confirmDismiss: (DismissDirection direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        )),
                                    content:
                                        const Text("Contact will be deleted"),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("DELETE",
                                              style: TextStyle(
                                                  color: Colors.redAccent))),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("CANCEL",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListTile(
                                      tileColor: Colors.transparent,
                                      selectedTileColor: Colors.transparent,
                                      leading: CircleAvatar(
                                        child: Text(
                                            _users[index]['first_name'][0],
                                            //_users[index]['last_name'][0],
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: index % 2 == 0
                                                    ? Colors.black
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      title: Text(
                                        _name(_users[index]),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: index % 2 == 0
                                              ? Colors.black
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      // subtitle: Text(_phonenum(_users[index]),
                                      //     style: TextStyle(
                                      //       color: index % 2 == 0
                                      //           ? Colors.black
                                      //           : Colors.black,
                                      //     )),
                                      onTap: () {
                                        List<int> listNumbers = [];
                                        for (int i = 0;
                                            i <
                                                _users[index]['phone_numbers']
                                                    .length;
                                            i++) {
                                          listNumbers.add(i + 1);
                                        }
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: AlertDialog(
                                                    title: Text(
                                                      _name(_users[index]),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 24),
                                                    ),
                                                    content: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          UpdateContact(
                                                                              specificID: _users[index]['_id'].toString()),
                                                                    ),
                                                                    (_) => false);
                                                              },
                                                              child: const Text(
                                                                'EDIT',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children:
                                                                List.generate(
                                                              listNumbers
                                                                  .length,
                                                              (iter) {
                                                                return Column(
                                                                  children: [
                                                                    // SizedBox(
                                                                    //   height:
                                                                    //       10,
                                                                    // ),
                                                                    Text(
                                                                      'Phone #' +
                                                                          listNumbers[iter]
                                                                              .toString() +
                                                                          ':\t\t' +
                                                                          _users[index]['phone_numbers'][iter]
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 15, 0, 30),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, 'OK'),
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blueAccent,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    actionsPadding:
                                                        EdgeInsets.fromLTRB(
                                                            24, 0, 0, 0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    onRefresh: _getData,
                  )
                : Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      backgroundColor: Colors.white,
                    ),
                  );
          },
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateNewContact()));
              Align(alignment: Alignment.bottomCenter);
            },
            child: Icon(
              Icons.add,
            ),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAuthKeyData();
  }

  Future<void> _getData() async {
    setState(() {
      Fluttertoast.showToast(msg: "Saved Contacts");
      getAuthKeyData();
    });
  }
}
