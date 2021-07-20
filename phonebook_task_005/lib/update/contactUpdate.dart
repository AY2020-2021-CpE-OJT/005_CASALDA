import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:phonebook_task_005/update/confirmUpdate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactDataUpdate {
  final String lastName;
  final String firstName;
  final List<String> phoneNumbers;

  ContactDataUpdate(this.lastName, this.firstName, this.phoneNumbers);
}

Future<SpecificContact> fetchSpecificContact(String id) async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  var authKeyObtained = sharedPreferences.getString('authKey');
  final response = await http.get(
      Uri.parse('https://kc-api-005.herokuapp.com/api/posts/get/' + id),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'auth-token': authKeyObtained.toString(),
      });
  print('Status [Success]: Got the ID [$id]');
  if (response.statusCode == 200) {
    print('Status [Success]: Specific Data Appended');
    return SpecificContact.fromJson(json.decode(response.body));
  } else {
    throw Exception('Status [Failed]: Cannot load Contact');
  }
}

class SpecificContact {
  SpecificContact({
    required this.phoneNumbers,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.v,
  });

  List<String> phoneNumbers;
  String id;
  String firstName;
  String lastName;
  int v;

  factory SpecificContact.fromJson(Map<String, dynamic> json) =>
      SpecificContact(
        phoneNumbers: List<String>.from(json["phone_numbers"].map((x) => x)),
        id: json["_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        v: json["__v"],
      );
}

class UpdateContact extends StatefulWidget {
  final String specificID;

  const UpdateContact({Key? key, required this.specificID}) : super(key: key);

  @override
  _UpdateContactState createState() => _UpdateContactState(specificID);
}

class _UpdateContactState extends State<UpdateContact> {
  String specificID;

  _UpdateContactState(this.specificID);

  late Future<SpecificContact> futureSpecificContact;

  int checkAdd = 0, listNumber = 1, _count = 1;
  String val = '';
  RegExp digitValidator = RegExp("[0-9]+");
  bool defaultVal = true;
  bool isANumber = true;
  String fname = '', lname = '';

  var fnameController = TextEditingController();
  var lnameController = TextEditingController();

  List<TextEditingController> pnumControllers = <TextEditingController>[
    TextEditingController()
  ];

  final FocusNode fnameFocus = FocusNode();
  final FocusNode lnameFocus = FocusNode();

  List<SpecificContact> contactsAppend = <SpecificContact>[];
  List<ContactDataUpdate> contactsAppendSave = <ContactDataUpdate>[];

  void saveContact() {
    List<String> pnums = <String>[];
    for (int i = 0; i < _count; i++) {
      pnums.add(pnumControllers[i].text);
    }
    List<String> reversedpnums = pnums.reversed.toList();
    setState(() {
      contactsAppendSave.insert(
          0,
          ContactDataUpdate(
              lnameController.text, fnameController.text, reversedpnums));
    });
    print('Status Append Contacts [Success]');
  }

  @override
  void initState() {
    super.initState();
    _count = 1;
    futureSpecificContact = fetchSpecificContact(specificID);
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    for (int i = 0; i < _count; i++) {
      pnumControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Color(0xFFF6EDE7),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Update Contact", style: TextStyle(color: Colors.black)),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            child: FutureBuilder<SpecificContact>(
              future: futureSpecificContact,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String? name1 =
                      Text(snapshot.data!.firstName.toString()).data;
                  String? name2 = Text(snapshot.data!.lastName.toString()).data;
                  List<String> listPhonenums = <String>[];
                  for (int i = 0; i < snapshot.data!.phoneNumbers.length; i++) {
                    listPhonenums.add(snapshot.data!.phoneNumbers[i]);
                  }
                  List<String> reverseNumbers = listPhonenums.reversed.toList();
                  return namesForm(name1!, name2!, reverseNumbers, context);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    backgroundColor: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("CANCEL",
                    style: TextStyle(color: Colors.redAccent))),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (_) => false);
              },
              child:
                  const Text("CONFIRM", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
    return new Future.value(true);
  }

  namesForm(String contentFname, String contentLname,
      List<String> listPhonenums, context) {
    if (_count == 1) {
      fnameController = TextEditingController(text: contentFname);
      lnameController = TextEditingController(text: contentLname);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: fnameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              focusNode: fnameFocus,
              onFieldSubmitted: (term) {
                _fieldFocusChange(context, fnameFocus, lnameFocus);
              },
              decoration: new InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                disabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                labelText: 'First name',
                labelStyle: TextStyle(
                  color: fnameFocus.hasFocus ? Colors.black : Colors.grey,
                ),
                prefixIcon:
                    Icon(Icons.account_box_rounded, color: Colors.black),
                suffixIcon: IconButton(
                  onPressed: fnameController.clear,
                  icon: Icon(Icons.cancel, color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: lnameController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              focusNode: lnameFocus,
              decoration: new InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                disabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                labelText: 'Last Name',
                labelStyle: TextStyle(
                  color: lnameFocus.hasFocus ? Colors.black : Colors.grey,
                ),
                prefixIcon:
                    Icon(Icons.account_box_rounded, color: Colors.black),
                suffixIcon: IconButton(
                  onPressed: lnameController.clear,
                  icon: Icon(Icons.cancel, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Text("Contact Number/s: $listNumber",
            //     style: TextStyle(color: Colors.black)),
            SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: _count,
                  itemBuilder: (context, index) {
                    return _row(index, listPhonenums, context);
                  }),
            ),
            SizedBox(height: 20),
            FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: const Text("Confirm",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      content: const Text("Tap on Confirm to Save Changes"),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text("CANCEL",
                                style: TextStyle(color: Colors.redAccent))),
                        TextButton(
                          onPressed: () {
                            saveContact();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateScreen(
                                          todo: contactsAppendSave,
                                          specificID: specificID,
                                        )),
                                (_) => false);
                          },
                          child: const Text("CONFIRM",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.save),
              label: Text("Save"),
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  _row(int key, List<String> listPhonenums, context) {
    if (_count >= 1 && _count <= listPhonenums.length && _count != key) {
      if (defaultVal == true) {
        pnumControllers[key] = TextEditingController(text: listPhonenums[key]);
        if (key == listPhonenums.length - 1) {
          defaultVal = false;
        }
      }
    } else {
      defaultVal = false;
    }

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            controller: pnumControllers[key],
            textCapitalization: TextCapitalization.sentences,
            onTap: () {
              setState(() {
                lnameFocus.hasFocus ? Colors.black : Colors.grey;
                fnameFocus.hasFocus ? Colors.black : Colors.grey;
              });
            },
            //maxLength: 13,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: new InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              disabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.redAccent,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.redAccent,
                ),
              ),
              errorText: isANumber ? null : "Please enter a number",
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              labelText: 'Phone number',
              labelStyle: TextStyle(
                color: Colors.grey,
              ),
              prefixIcon:
                  Icon(Icons.phone_android_rounded, color: Colors.black),
              suffixIcon: IconButton(
                onPressed: pnumControllers[key].clear,
                icon: Icon(Icons.cancel, color: Colors.black),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: _addRemoveButton(key == checkAdd, key),
          ),
        ),
      ],
    );
  }

  void setValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }

  Widget _addRemoveButton(bool isTrue, int index) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (isTrue) {
          setState(() {
            _count++;
            checkAdd++;
            listNumber++;
            pnumControllers.insert(0, TextEditingController());
          });
        } else {
          setState(() {
            _count--;
            checkAdd--;
            listNumber--;
            pnumControllers.removeAt(index);
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: (isTrue) ? Colors.blueAccent : Colors.redAccent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(
          (isTrue) ? Icons.add : Icons.remove,
          color: Colors.white70,
        ),
      ),
    );
  }
}

_fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
