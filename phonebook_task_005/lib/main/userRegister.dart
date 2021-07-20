import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phonebook_task_005/main/menu.dart';
import 'package:phonebook_task_005/model/userModel.dart';
import 'package:phonebook_task_005/processes/progressIndicator.dart';
import 'package:phonebook_task_005/processes/api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassword = true;
  FocusNode nameFocus = new FocusNode();
  FocusNode emailFocus = new FocusNode();
  FocusNode passwordFocus = new FocusNode();

  late RegisterRequestModel regRequestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    nameFocus = FocusNode();
    emailFocus = FocusNode();
    passwordFocus = FocusNode();
    regRequestModel =
        new RegisterRequestModel(name: '', email: '', password: '');
  }

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: buildUIRegister(context),
      inAsyncCall: isApiCallProcess,
    );
  }

  Widget buildUIRegister(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: GestureDetector(
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Theme.of(context).primaryColor,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Form(
                          key: globalFormKey,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Register as New User",
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              new TextFormField(
                                focusNode: nameFocus,
                                onTap: _requestFocusName,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                onSaved: (input) =>
                                    regRequestModel.name = input!,
                                validator: (input) => input!.length < 6
                                    ? "Username should be more than 6 characters"
                                    : null,
                                decoration: new InputDecoration(
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
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                    color: nameFocus.hasFocus
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              new TextFormField(
                                focusNode: emailFocus,
                                onTap: _requestFocusEmail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onSaved: (input) =>
                                    regRequestModel.email = input!,
                                validator: (input) => !input!.contains("@")
                                    ? "Email Address invalid"
                                    : null,
                                decoration: new InputDecoration(
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
                                  labelText: 'Email Address',
                                  labelStyle: TextStyle(
                                    color: emailFocus.hasFocus
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              new TextFormField(
                                focusNode: passwordFocus,
                                onTap: _requestFocusPassword,
                                keyboardType: TextInputType.text,
                                onSaved: (input) =>
                                    regRequestModel.password = input!,
                                validator: (input) => input!.length < 3
                                    ? "Password is less than 6 characters"
                                    : null,
                                obscureText: hidePassword,
                                decoration: new InputDecoration(
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
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: passwordFocus.hasFocus
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.4),
                                      icon: Icon(hidePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    primary: Colors.black,
                                    onPrimary: Colors.white,
                                  ),
                                  onPressed: () {
                                    int timeout = 60;
                                    int alertTime = 3;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (validateAndSave()) {
                                      setState(() {
                                        isApiCallProcess = true;
                                      });
                                      RegisterService apiService =
                                          new RegisterService();
                                      apiService.login(regRequestModel).then(
                                        (value) {
                                          setState(() {
                                            isApiCallProcess = false;
                                          });
                                          if (value.message.isNotEmpty) {
                                            globalFormKey.currentState!.reset();
                                            return showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return new AlertDialog(
                                                  title: Row(
                                                    children: [
                                                      Icon(Icons.error,
                                                          color: Colors.white),
                                                      Text(
                                                        "  Registered",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content:
                                                      new Text(value.message),
                                                  actions: <Widget>[
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator
                                                              .pushNamedAndRemoveUntil(
                                                                  context,
                                                                  '/menu',
                                                                  (_) => false);
                                                        },
                                                        child: const Text("OK",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black))),
                                                  ],
                                                );
                                              },
                                            ).timeout(
                                              Duration(seconds: alertTime),
                                              onTimeout: () {
                                                Navigator.of(context).pop();
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        '/menu',
                                                        (_) => false);
                                              },
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return new AlertDialog(
                                                  title: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.error,
                                                        color: Colors.redAccent,
                                                      ),
                                                      Text(
                                                        "  Register",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content:
                                                      new Text(value.error),
                                                  actions: <Widget>[
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text("OK",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black))),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ).timeout(
                                        Duration(seconds: timeout),
                                        onTimeout: () {
                                          globalFormKey.currentState!.reset();
                                          setState(() {
                                            isApiCallProcess = false;
                                          });
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _requestFocusName() {
    setState(() {
      FocusScope.of(context).requestFocus(nameFocus);
    });
  }

  void _requestFocusEmail() {
    setState(() {
      FocusScope.of(context).requestFocus(emailFocus);
    });
  }

  void _requestFocusPassword() {
    setState(() {
      FocusScope.of(context).requestFocus(passwordFocus);
    });
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _onBackPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: const Text("Are you sure?",
              style: TextStyle(
                color: Colors.black,
              )),
          content: const Text("Account creation will be stopped"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainMenu()),
                    (_) => false);
              },
              child: const Text(
                "CONFIRM",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                "CANCEL",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
    return new Future.value(true);
  }
}
