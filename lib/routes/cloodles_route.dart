import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloodle/widgets/cloodle_tile.dart';
import 'package:cloodle/models/user.dart';

class CloodlesRoute extends StatelessWidget {
  final User currentUser;

  CloodlesRoute({this.currentUser});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Cloodles List'),
      ),
      body: new Column(
        children: <Widget>[
          _displayCloodlesList(),
        ],
      ),
    );
  }

  Widget _displayCloodlesList() {
    var _db = Firestore.instance
        .collection('users')
        .document(this.currentUser.uid)
        .collection("sessions");
    return new StreamBuilder(
      stream: _db.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final sessions = snapshot.data.documents;
        return new Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(8.0),
            reverse: false,
            itemBuilder: (_, int index) => new CloodleTile(
                  session_id: sessions[index].documentID,
                  from: sessions[index]['FROM'],
                  from_name: sessions[index]['FROM_NAME'],
                  image_name: sessions[index]['IMAGE_NAME'],
                ),
            itemCount: snapshot.data.documents.length,
          ),
        );
      },
    );
  }
}
