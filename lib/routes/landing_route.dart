import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

import 'package:cloodle/routes/camera_route.dart';

class LandingRoute extends StatefulWidget {
  final List<CameraDescription> cameras;

  LandingRoute({this.cameras});

  @override
  LandingRouteState createState() {
    return new LandingRouteState();
  }
}

class LandingRouteState extends State<LandingRoute> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = new FirebaseMessaging();
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  void initState() {
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: ${message}");
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: ${message}");
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: ${message}");
      },
    );

    _messaging.getToken().then((token) {
      print("Token: ${token}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Cloodle'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            new RaisedButton(
                onPressed: () =>
                    _handleSignIn(context).then((FirebaseUser user) {
                      saveUserToFirebase(user);
                      sendWelcomeNotification();
                    }).catchError((e) => print(e)),
                child: new Text("Sign In With Google"),
                color: Colors.red),
            new Padding(
              padding: const EdgeInsets.all(10.0),
              child: new RaisedButton(
                  onPressed: () => googleSignIn.signOut(),
                  child: new Text("Sign Out"),
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Future<FirebaseUser> _handleSignIn(BuildContext context) async {
    var user = await _auth.currentUser();
    if (user == null) {
      GoogleSignInAccount gUser = googleSignIn.currentUser;

      if (gUser == null) {
        gUser = await googleSignIn.signInSilently();
        if (gUser == null) {
          gUser = await googleSignIn.signIn();
        }
      }

      GoogleSignInAuthentication gAuth = await gUser.authentication;
      user = await _auth.signInWithGoogle(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      print("Signed in as " + user.displayName);
    }

    return user;
    // Navigator.of(context).push(
    //   new MaterialPageRoute<void>(
    //     // Add 20 lines from here...
    //     builder: (BuildContext context) {
    //       return new CameraRoute(cameras: cameras);
    //     },
    //   ),
    // );
  }

  Future<void> saveUserToFirebase(FirebaseUser user) async {
    print('saving user to firebase');
    var token = await _messaging.getToken();

    // await saveUserToPreferences(user.uid, user.displayName, token);

    var update = {
      "NAME": user.displayName,
      "PHOTO_URL": user.photoUrl,
      "NOTIFICATION_TOKEN": token
    };
    print(update);

    return Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData(update);
  }

  void sendWelcomeNotification() async {
    var token = await _messaging.getToken();
    var base = 'https://us-central1-cloodle-v1.cloudfunctions.net/';
    String dataURL = '$base/sendNotification?to=$token';
    print(dataURL);
    http.Response response = await http.get(dataURL);
  }
}
