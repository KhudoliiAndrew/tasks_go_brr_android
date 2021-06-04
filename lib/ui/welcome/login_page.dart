import 'package:flutter/material.dart';
import 'package:simple_todo_flutter/resources/colors.dart';
import 'package:simple_todo_flutter/ui/custom/animated_gesture_detector.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedGestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  color: context.primary,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Text(
                "Sign in with Google"
              ),
            )),
      ),
    );
  }
}
