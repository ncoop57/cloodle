import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloodle/routes/cloodle_route.dart';
import 'package:cloodle/models/session.dart';

class CloodleTile extends StatelessWidget {
  final Session session;
  final String type;

  CloodleTile({
    this.session,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        color: (this.session.answer == 0)
            ? Colors.white
            : (this.session.answer == 1) ? Colors.green : Colors.red,
      ),
      child: new ListTile(
        title: new Text(
          (this.type == "TO") ? this.session.fromName : this.session.toName,
        ),
        leading: new FutureBuilder<dynamic>(
          future: FirebaseStorage.instance
              .ref()
              .child('cloodles/${this.session.imageName}')
              .getDownloadURL(), // a Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return new Container();
              case ConnectionState.waiting:
                return new Container();
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else
                  return new Image.network(snapshot.data);
            }
          },
        ),
        onTap: () => _handleCloodle(context),
      ),
    );
  }

  void _handleCloodle(BuildContext context) {
    print("You clicked a cloodle!");
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new CloodleRoute(session: this.session, type: this.type);
        },
      ),
    );
  }

  // void saveCloodleSessionToFirebase(String imageName) async {
  //   print('saving session to firebase');

  //   // await saveUserToPreferences(user.uid, user.displayName, token);

  //   var session = {
  //     "FROM": fromUser.uid,
  //     "TO": toUser.uid,
  //     "guess": "",
  //     "answer": "",
  //     "imageName": imageName,
  //   };
  //   print(session);

  //   Firestore.instance
  //       .collection('users')
  //       .document(fromUser.uid)
  //       .collection("sessions")
  //       .document()
  //       .setData(session);

  //   Firestore.instance
  //       .collection('users')
  //       .document(toUser.uid)
  //       .collection("sessions")
  //       .document()
  //       .setData(session);
  // }
}
