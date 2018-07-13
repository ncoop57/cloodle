import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

import 'package:cloodle/cloud_editor_route.dart';

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
      home: new CloodleCamera(),
    );
  }
}

String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

class CloodleCamera extends StatefulWidget {
  @override
  CloodleCameraState createState() {
    return new CloodleCameraState();
  }
}

class CloodleCameraState extends State<CloodleCamera> {
  CameraController controller;
  String imagePath;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = new CameraController(_cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) return;

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('Cloodle'),
      ),
      body: new Column(
        children: [
          new Expanded(
            child: new Container(
              child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                  child: _cameraPreview(),
                ),
              ),
            ),
          ),
          new IconButton(
            icon: const Icon(Icons.camera_alt),
            color: Colors.blue,
            onPressed: controller != null &&
                    controller.value.isInitialized &&
                    !controller.value.isRecordingVideo
                ? onTakePictureButtonPressed
                : null,
          ),
        ],
      ),
    );
  }

  Widget _cameraPreview() {
    if (!controller.value.isInitialized) {
      return new Container();
    }

    return new AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: new CameraPreview(controller),
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });

        var ref = FirebaseStorage.instance.ref().child(imagePath);
        var uploadTask = ref.put(new File(imagePath));

        if (filePath != null) print('Picture saved to $filePath');
        Navigator.of(context).push(
          new MaterialPageRoute<void>(
            // Add 20 lines from here...
            builder: (BuildContext context) {
              return CloudEditorRoute(imagePath: imagePath);
            },
          ),
        );
      }
    });
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: imagePath == null
            ? null
            : new SizedBox(
                child: new Image.file(new File(imagePath)),
                width: 64.0,
                height: 64.0,
              ),
      ),
    );
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    print(filePath);

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }
}
