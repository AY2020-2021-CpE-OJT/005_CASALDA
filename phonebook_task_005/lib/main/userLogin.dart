import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phonebook_task_005/processes/progressIndicator.dart';
import 'package:phonebook_task_005/processes/api.dart';
import 'package:phonebook_task_005/model/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassword = true;
  FocusNode emailFocus = new FocusNode();
  FocusNode passwordFocus = new FocusNode();

  late LoginRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    emailFocus = FocusNode();
    passwordFocus = FocusNode();
    requestModel = new LoginRequestModel(email: '', password: '');
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: buildUI(context),
      inAsyncCall: isApiCallProcess,
    );
  }

  Widget buildUI(BuildContext context) {
    return GestureDetector(
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
                                  "User Login",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            new TextFormField(
                              focusNode: emailFocus,
                              onTap: _requestFocusEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onSaved: (input) => requestModel.email = input!,
                              validator: (input) => !input!.contains("@")
                                  ? "Invalid Email"
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
                                  requestModel.password = input!,
                              validator: (input) => input!.length < 6
                                  ? "Minimum of 6 characters"
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
                                  icon: Icon(hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ),
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
                                onPressed: () async {
                                  int timeout = 60;
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  final SharedPreferences sharedPreferences =
                                      await SharedPreferences.getInstance();
                                  if (validateAndSave()) {
                                    setState(() {
                                      isApiCallProcess = true;
                                    });
                                    APIService apiService = new APIService();
                                    apiService.login(requestModel).then(
                                      (value) {
                                        setState(() {
                                          isApiCallProcess = false;
                                        });
                                        if (value.authToken.isNotEmpty) {
                                          sharedPreferences.setString('data',
                                              requestModel.toJson().toString());
                                          sharedPreferences.setString('authKey',
                                              value.authToken.toString());
                                          sharedPreferences.setString(
                                              'currentUser',
                                              value.message.toString());
                                          globalFormKey.currentState!.reset();
                                          Navigator.pushNamedAndRemoveUntil(
                                              context, '/home', (_) => false);
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
                                                      "  Login",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                                content: new Text(value.error),
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
                                        sharedPreferences.remove('data');
                                        sharedPreferences.remove('authKey');
                                        setState(() {
                                          isApiCallProcess = false;
                                        });
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            new GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.only(
                                  bottom: 5,
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
    );
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
}
