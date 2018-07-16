import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

import 'package:cloodle/routes/cloodle_route.dart';
import 'package:cloodle/models/user.dart';

class CloodleTile extends StatelessWidget {
  final String session_id;
  final String from;
  final String from_name;
  final String image_name;

  CloodleTile({this.session_id, this.from, this.from_name, this.image_name});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(
        from_name,
      ),
      onTap: () => _handleCloodle(context),
    );
  }

  void _handleCloodle(BuildContext context) {
    print("You clicked a cloodle!");

    // var imageName = basename(imagePath);
    // saveCloodleSessionToFirebase(imageName);
    // var ref = FirebaseStorage.instance.ref().child("cloodles/" + imageName);
    // StorageUploadTask putFile = ref.putFile(new File(imagePath));
    // putFile.future.then((UploadTaskSnapshot upload) async {
    //   print("file uploaded");
    //   var base =
    //       'https://us-central1-cloodle-v1.cloudfunctions.net/sendNotification';

    //   String dataURL =
    //       '$base?to=${this.toUser.notification_token}&fromPushId=${fromUser.notification_token}&fromName=${fromUser.name}&imageName=$imageName';
    //   dataURL = Uri.encodeFull(dataURL);
    //   print(dataURL);
    //   http.Response response = await http.get(dataURL);
    // });

    // Navigator.pop(context);
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
