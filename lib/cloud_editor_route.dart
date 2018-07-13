import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class CloudEditorRoute extends StatefulWidget {
  final String imagePath;

  CloudEditorRoute({this.imagePath});

  @override
  CloudEditorRouteState createState() {
    return new CloudEditorRouteState();
  }
}

class CloudEditorRouteState extends State<CloudEditorRoute> {
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
        ],
      ),
    );
  }
}
