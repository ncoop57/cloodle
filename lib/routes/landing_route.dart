import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:cloodle/routes/camera_route.dart';

class LandingRoute extends StatelessWidget {
  final List<CameraDescription> cameras;

  LandingRoute({this.cameras});

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
                onPressed: () => _handleSignIn(context),
                child: new Text("Sign In"),
                color: Colors.green),
            new Padding(
              padding: const EdgeInsets.all(10.0),
              child: new RaisedButton(
                  onPressed: null,
                  child: new Text("Sign Up"),
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignIn(BuildContext context) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        // Add 20 lines from here...
        builder: (BuildContext context) {
          return new CameraRoute(cameras: cameras);
        },
      ),
    );
  }
}
