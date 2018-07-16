import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:camera/camera.dart';

import 'package:cloodle/routes/camera_route.dart';
import 'package:cloodle/routes/cloodle_route.dart';
import 'package:cloodle/models/user.dart';

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
  User currentUser;

  @override
  void initState() {
    super.initState();
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        _handleSignIn(context).then((FirebaseUser user) {
          saveUserToFirebase(user);
          _handleNotification(message);
        });
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
        _handleSignIn(context).then((FirebaseUser user) {
          saveUserToFirebase(user);
          _handleNotification(message);
        });
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
        _handleSignIn(context).then((FirebaseUser user) {
          saveUserToFirebase(user);
          _handleNotification(message);
        });
      },
    );

    _messaging.getToken().then((token) {
      print("Token: $token");
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
                      // sendWelcomeNotification();
                      Navigator.of(context).push(
                        new MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return new CameraRoute(
                                cameras: widget.cameras,
                                currentUser: currentUser);
                          },
                        ),
                      );
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
  }

  Future<void> saveUserToFirebase(FirebaseUser user) async {
    print('saving user to firebase');
    var token = await _messaging.getToken();
    currentUser = new User(
        name: user.displayName,
        photo_url: user.photoUrl,
        notification_token: token,
        uid: user.uid);

    // await saveUserToPreferences(user.uid, user.displayName, token);

    var update = {
      "NAME": user.displayName,
      "PHOTO_URL": user.photoUrl,
      "NOTIFICATION_TOKEN": token,
      "UID": user.uid,
    };
    print(update);

    return Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData(update);
  }

  void _handleNotification(Map<String, dynamic> message) {
    _handleSignIn(context);
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          // String imageName = getValueFromMap(message, 'imageName');
          return new CloodleRoute(
              imageName: message['imageName'], currentUser: currentUser);
        },
      ),
    );
  }
}
