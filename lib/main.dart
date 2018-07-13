import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:cloodle/routes/landing_route.dart';

List<CameraDescription> _cameras;

Future<Null> main() async {
  _cameras = await availableCameras();
  runApp(new App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cloodle',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LandingRoute(cameras: _cameras),
    );
  }
}
