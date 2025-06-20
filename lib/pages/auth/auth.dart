import 'package:flutter/widgets.dart';
import 'package:ponder_app/pages/auth/signIn.dart';
import 'package:ponder_app/pages/auth/signUp.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => AuthenticationState();
}

class AuthenticationState extends State<Authentication> {
  bool isLogin = true;

  void changeMode(bool mode) {
    setState(() {
      isLogin = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return Signin(
        setMode: changeMode,
      );
    } else {
      return Signup(setMode: changeMode);
    }
  }
}
