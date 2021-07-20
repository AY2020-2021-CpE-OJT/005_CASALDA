import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phonebook_task_005/main/userRegister.dart';
import 'userLogin.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late DateTime currentBackPressTime;
  late final _controllerAnimation;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controllerAnimation =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controllerAnimation);
  }

  @override
  void dispose() {
    super.dispose();
    _controllerAnimation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressed;
    _controllerAnimation.forward();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          final maxDuration = Duration(seconds: 1);
          final isWarning =
              lastPressed == null || now.difference(lastPressed!) > maxDuration;
          if (isWarning) {
            lastPressed = DateTime.now();
            Fluttertoast.showToast(
                msg: "Double Tap to Close App",
                toastLength: Toast.LENGTH_SHORT);
            return false;
          } else {
            Fluttertoast.cancel();
            return true;
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FadeTransition(
                  opacity: _animation,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Phonebook",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FadeTransition(
                  opacity: _animation,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.2),
                                offset: Offset(0, 10),
                                blurRadius: 20),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    primary: Colors.black,
                                    onPrimary: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                  );
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
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                    side: BorderSide(
                                        color: Colors.black, width: 3),
                                  ),
                                  primary: Colors.black,
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterScreen()),
                                      (_) => false);
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
