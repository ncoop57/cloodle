import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

import 'package:cloodle/routes/editor_route.dart';
import 'package:cloodle/routes/cloodles_list_route.dart';

String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

class CameraRoute extends StatefulWidget {
  final List<CameraDescription> cameras;
  final currentUser;

  CameraRoute({this.cameras, this.currentUser});

  @override
  CameraRouteState createState() {
    return new CameraRouteState();
  }
}

class CameraRouteState extends State<CameraRoute> {
  CameraController controller;
  String imagePath;
  String imageName;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = new CameraController(widget.cameras[0], ResolutionPreset.high);
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
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.list),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                new MaterialPageRoute<void>(
                  // Add 20 lines from here...
                  builder: (BuildContext context) {
                    return CloodlesListRoute(
                      currentUser: widget.currentUser,
                    );
                  },
                ),
              );
            },
          ),
        ],
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

        if (filePath != null) print('Picture saved to $filePath');
        Navigator.of(context).push(
          new MaterialPageRoute<void>(
            // Add 20 lines from here...
            builder: (BuildContext context) {
              return EditorRoute(
                  imagePath: imagePath, currentUser: widget.currentUser);
            },
          ),
        );
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

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
