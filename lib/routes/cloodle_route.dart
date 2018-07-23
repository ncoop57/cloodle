import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloodle/models/session.dart';

class CloodleRoute extends StatelessWidget {
  final _textController = new TextEditingController();
  final Session session;
  final String type;

  CloodleRoute({this.session, this.type});

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
                    .child('cloodles/${this.session.imageName}')
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
          (this.type == "TO")
              ? (this.session.answer == 0)
                  ? _buildQuiz(context)
                  : new Text(
                      "YOU GOT IT ${(this.session.answer == -1) ? "WRONG" : "RIGHT"}!")
              : (this.session.guess == "")
                  ? new Text("${this.session.toName} has not made a guess yet.")
                  : _buildAnswer(context),
        ],
      ),
    );
  }

  Widget _buildQuiz(BuildContext context) {
    return new Row(
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
    );
  }

  Widget _buildAnswer(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(
              "${this.session.toName} guessed: ${this.session.guess}. Are they correct?"),
        ),
        (this.session.answer != 0)
            ? new Text(
                "You said ${(this.session.answer == 1) ? "correct" : "incorrect"}!")
            : new Row(
                children: [
                  new IconButton(
                    icon: new Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    onPressed: () => _updateSessionToFireBase(1),
                  ),
                  new IconButton(
                    icon: new Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                    onPressed: () => _updateSessionToFireBase(-1),
                  ),
                ],
              ),
      ],
    );
  }

  void _handleSubmitted(BuildContext context) {
    if (_textController.text.isNotEmpty) {
      print('Answered');
      _updateSessionToFireBase(0);

      Navigator.of(context).pop();
    }
  }

  Future<void> _updateSessionToFireBase(int answer) async {
    var session = {
      "FROM": this.session.from,
      "FROM_NAME": this.session.fromName,
      "TO": this.session.to,
      "TO_NAME": this.session.toName,
      "GUESS": (answer == 0) ? _textController.text : this.session.guess,
      "ANSWER": answer,
      "IMAGE_NAME": this.session.imageName,
    };

    return Firestore.instance
        .collection("sessions")
        .document(this.session.sessionId)
        .setData(session);
  }
}
