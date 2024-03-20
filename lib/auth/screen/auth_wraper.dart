import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/auth/screen/login.dart';
import 'package:my_chat/screens/home_screen.dart';

class AuthWraper extends StatefulWidget {
  const AuthWraper({super.key});

  @override
  State<AuthWraper> createState() => _AuthWraperState();
}

class _AuthWraperState extends State<AuthWraper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      if (Apis.auth.currentUser != null) {
        // print("\n User : ${Apis.auth.currentUser}");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Lottie.asset('assets/lottie_animation/1.json',
              width: 300, height: 300, fit: BoxFit.cover, reverse: true)),
    );
  }
}
