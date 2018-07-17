import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloodle/models/session.dart';

class CloodleRoute extends StatelessWidget {
  final _textController = new TextEditingController();
  final Session session;

  CloodleRoute({this.session});

  @override
  Widget build(BuildContext context) {
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
                    .child('cloodles/${this.session.image_name}')
                    .getDownloadURL(),
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
      // _updateSessionToFireBase().then((onValue) async {
      //   var base =
      //       'https://us-central1-cloodle-v1.cloudfunctions.net/sendNotification';

      //   String dataURL = '$base?to=${this.session.from}' +
      //       '&fromPushId=${this.session.to}' +
      //       '&fromName=${this.session.to_name}' +
      //       '&imageName=${this.session.image_name}' +
      //       '&type=reply';
      //   dataURL = Uri.encodeFull(dataURL);
      //   print(dataURL);
      //   http.Response response = await http.get(dataURL);
      // });
      print('Answered');

      Navigator.of(context).pop();
    }
  }

  // Future<void> _updateSessionToFireBase() async {
  //   var session = {
  //     "FROM": this.session.from,
  //     "FROM_NAME": this.session.from_name,
  //     "TO": this.session.to,
  //     "GUESS": _textController.text,
  //     "ANSWER": "",
  //     "IMAGE_NAME": this.session.image_name,
  //   };

  //   Firestore.instance
  //       .collection('users')
  //       .document(this.session.from)
  //       .collection("sessions")
  //       .document(this.session.session_id)
  //       .setData(session);

  //   return Firestore.instance
  //       .collection('users')
  //       .document(this.session.to)
  //       .collection("sessions")
  //       .document()
  //       .setData(session);
  // }
}
