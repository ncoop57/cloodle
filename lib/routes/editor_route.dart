import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:cloodle/routes/friends_list_route.dart';
import 'package:cloodle/models/user.dart';
import 'package:cloodle/models/cloodle_painter.dart';

class EditorRoute extends StatefulWidget {
  final User currentUser;
  final String imagePath;

  EditorRoute({this.imagePath, this.currentUser});

  @override
  EditorRouteState createState() {
    return new EditorRouteState();
  }
}

class EditorRouteState extends State<EditorRoute> {
  List<Offset> _points = <Offset>[];

  Future<ui.Image> _loadImage() async {
    var assetImage = new ExactAssetImage(widget.imagePath);
    var key = await assetImage.obtainKey(new ImageConfiguration());

    final ByteData data = await key.bundle.load(key.name);
    if (data == null) throw 'Unable to read data';
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    // add additional checking for number of frames etc here
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Cloodle Editors'),
      ),
      body: new Container(
        child: new GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox object = context.findRenderObject();
              Offset _localPosition =
                  object.globalToLocal(details.globalPosition);
              _points = new List.from(_points)..add(_localPosition);
            });
          },
          onPanEnd: (DragEndDetails details) => _points.add(null),
          child: new FutureBuilder<ui.Image>(
            future: _loadImage(),
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Image loading...');
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else
                    // ImageCanvasDrawer would be a (most likely) statless widget
                    // that actually makes the CustomPaint etc
                    return new CustomPaint(
                      painter: new CloodlePainter(
                        image: snapshot.data,
                        points: _points,
                      ),
                      size: Size.infinite,
                    );
              }
            },
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return new Scaffold(
  //     appBar: new AppBar(
  //       title: const Text('Cloodle Editors'),
  //     ),
  //     body: new Column(
  //       children: [
  //         new Expanded(
  //           child: new Align(
  //             alignment: Alignment.centerRight,
  //             child: widget.imagePath == null
  //                 ? null
  //                 : new Image.file(new File(widget.imagePath)),
  //           ),
  //         ),
  //         new IconButton(
  //           icon: const Icon(Icons.wb_cloudy),
  //           color: Colors.blue,
  //           onPressed: () => _handleSendCloodle(context),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _handleSendCloodle(BuildContext context) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new FriendsListRoute(
              imagePath: widget.imagePath, currentUser: widget.currentUser);
        },
      ),
    );
  }
}
