import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

import 'package:cloodle/routes/friends_route.dart';

class EditorRoute extends StatefulWidget {
  final String imagePath;

  EditorRoute({this.imagePath});

  @override
  EditorRouteState createState() {
    return new EditorRouteState();
  }
}

class EditorRouteState extends State<EditorRoute> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Cloodle Editors'),
      ),
      body: new Column(
        children: [
          new Expanded(
            child: new Align(
              alignment: Alignment.centerRight,
              child: widget.imagePath == null
                  ? null
                  : new Image.file(new File(widget.imagePath)),
            ),
          ),
          new IconButton(
            icon: const Icon(Icons.wb_cloudy),
            color: Colors.blue,
            onPressed: () => _handleSendCloodle(context),
          ),
        ],
      ),
    );
  }

  void _handleSendCloodle(BuildContext context) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new FriendsRoute(imagePath: widget.imagePath);
        },
      ),
    );
    // var ref = FirebaseStorage.instance
    //     .ref()
    //     .child("cloodles/" + basename(widget.imagePath));
    // ref.putFile(new File(widget.imagePath));
  }
}
