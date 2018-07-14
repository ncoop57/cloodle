import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'package:cloodle/models/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final String imagePath;

  UserTile({this.user, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(
        user.name,
      ),
      leading: new Image.network(
        user.photo_url,
      ),
      onTap: () => _handleSendCloodle(context),
    );
  }

  void _handleSendCloodle(BuildContext context) async {
    print("Sending cloodle!");

    var base =
        'https://us-central1-cloodle-v1.cloudfunctions.net/sendNotification';
    var imageName = basename(imagePath);
    String dataURL =
        '$base?to=${this.user.notification_token}&fromName=YoYoMa&imageName=$imageName';
    print(dataURL);
    http.Response response = await http.get(dataURL);

    Navigator.pop(context);
  }
}
