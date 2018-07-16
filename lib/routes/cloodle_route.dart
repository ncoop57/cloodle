import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloodle/models/user.dart';

class CloodleRoute extends StatelessWidget {
  final _textController = new TextEditingController();
  final User currentUser;
  final String imageName;

  CloodleRoute({this.imageName, this.currentUser});

  @override
  Widget build(BuildContext context) {
    // return new Container();
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Cloodle Quiz'),
      ),
      body: new Column(
        children: [
          new Expanded(
            child: new Align(
              alignment: Alignment.center,
              child: new FutureBuilder<dynamic>(
                future: FirebaseStorage.instance
                    .ref()
                    .child('cloodles/$imageName')
                    .getDownloadURL(), // a Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return new Text('Wait for it');
                    case ConnectionState.waiting:
                      return new Text(
                          'WAAAAAAAAIIIIIITTT FFFFFOOOOOORRR IIIIIIITTT');
                    default:
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      else
                        return new Image.network(snapshot.data);
                  }
                },
              ),
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(32.0)),
                    ),
                    hintText: 'What do you see?',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(context),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(BuildContext context) async {
    if (_textController.text.isNotEmpty) {
      Navigator.of(context).pop();
    }
  }
}
