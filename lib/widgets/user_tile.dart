import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
// import 'package:http/http.dart' as http;

import 'package:cloodle/models/user.dart';

class UserTile extends StatelessWidget {
  final User toUser;
  final User fromUser;
  final String imagePath;

  UserTile({this.toUser, this.fromUser, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(
        toUser.name,
      ),
      leading: new Image.network(
        toUser.photoUrl,
      ),
      onTap: () => _handleSendCloodle(context),
    );
  }

  void _handleSendCloodle(BuildContext context) {
    print("Sending cloodle!");

    var imageName = basename(imagePath);
    saveCloodleSessionToFirebase(imageName);
    var ref = FirebaseStorage.instance.ref().child("cloodles/" + imageName);
    StorageUploadTask putFile = ref.putFile(new File(imagePath));
    putFile.future.then((UploadTaskSnapshot upload) async {
      print("file uploaded");
      var base =
          'https://us-central1-cloodle-v1.cloudfunctions.net/sendNotification';

      String dataURL = '$base?to=${this.toUser.notificationToken}' +
          '&fromPushId=${fromUser.notificationToken}' +
          '&fromName=${fromUser.name}' +
          '&imageName=$imageName';
      dataURL = Uri.encodeFull(dataURL);
      print(dataURL);
      // await http.get(dataURL);
    });

    Navigator.pop(context);
  }

  void saveCloodleSessionToFirebase(String imageName) async {
    print('saving session to firebase');

    // await saveUserToPreferences(user.uid, user.displayName, token);

    var session = {
      "FROM": fromUser.notificationToken,
      "FROM_NAME": fromUser.name,
      "TO": toUser.notificationToken,
      "TO_NAME": toUser.name,
      "GUESS": "",
      "ANSWER": 0,
      "IMAGE_NAME": imageName,
    };
    print(session);

    Firestore.instance.collection('sessions').document().setData(session);
  }
}
