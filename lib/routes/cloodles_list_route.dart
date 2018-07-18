import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloodle/widgets/cloodle_tile.dart';
import 'package:cloodle/models/user.dart';
import 'package:cloodle/models/session.dart';

class CloodlesListRoute extends StatelessWidget {
  final User currentUser;

  CloodlesListRoute({this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.mail)),
              Tab(icon: Icon(Icons.send)),
            ],
          ),
          title: Text('Cloodles List'),
        ),
        body: TabBarView(
          children: [
            new Column(
              children: <Widget>[
                _displayCloodlesList("TO"),
              ],
            ),
            new Column(
              children: <Widget>[
                _displayCloodlesList("FROM"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayCloodlesList(String condition) {
    var _db = Firestore.instance
        .collection("sessions")
        .where(condition, isEqualTo: currentUser.notification_token);
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
                  session: new Session(
                    session_id: sessions[index].documentID,
                    from: sessions[index]['FROM'],
                    from_name: sessions[index]['FROM_NAME'],
                    to: sessions[index]['TO'],
                    to_name: sessions[index]['TO_NAME'],
                    image_name: sessions[index]['IMAGE_NAME'],
                    guess: sessions[index]['GUESS'],
                    answer: sessions[index]['ANSWER'],
                  ),
                  type: condition,
                ),
            itemCount: snapshot.data.documents.length,
          ),
        );
      },
    );
  }
}
