import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/helper/dialog.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isAnimate = true;
      });
    });
  }

  _handleGoogleButtonClick() {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if ((await Apis.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await Apis.createUser().then((user) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // triger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      //obtain the auth details from the request
      final GoogleSignInAuthentication? googlePath =
          await googleUser?.authentication;
      //create a new credential
      final credential = GoogleAuthProvider.credential(
          accessToken: googlePath?.accessToken, idToken: googlePath?.idToken);
      //once signed in, return the credential
      return await Apis.auth.signInWithCredential(credential);
    } catch (e) {
      print("\n sign In with google : $e");
      Dialogs.showSnackbar(context, "No internet");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome to Personal Chat",
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .10,
            right: isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            height: mq.height * .1,
            duration: Duration(seconds: 1),
            child: Image.asset('assets/images/message.png'),
          ),
          Center(
            child: Container(
              child: Lottie.asset(
                'assets/lottie_animation/5.json',
                width: 300,
                height: 300,
                fit: BoxFit.fill,
                repeat: true,
                reverse: false,
                animate: true,
              ),
            ),
          ),
          Positioned(
            bottom: mq.height * .1,
            right: mq.height * .05,
            width: mq.width * .5,
            height: mq.height * .06,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleGoogleButtonClick();
                // Navigator.pushReplacement(
                //     context, MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              icon: Icon(
                Icons.text_rotation_down,
                color: Colors.black,
              ),
              label: Text("Sign In with Google",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 112, 200, 243),
                  shape: StadiumBorder(),
                  elevation: 1),
            ),
          ),
        ],
      ),
    );
  }
}
