import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloodle/widgets/user_tile.dart';
import 'package:cloodle/models/user.dart';

class FriendsListRoute extends StatelessWidget {
  final String imagePath;
  final User currentUser;

  FriendsListRoute({this.imagePath, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Friends List'),
      ),
      body: new Column(
        children: <Widget>[
          _displayFriendsList(),
        ],
      ),
    );
  }

  Widget _displayFriendsList() {
    var _db = Firestore.instance.collection('users');
    return new StreamBuilder(
      stream: _db.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final users = snapshot.data.documents;
        return new Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(8.0),
            reverse: false,
            itemBuilder: (_, int index) => new UserTile(
                  toUser: new User(
                    name: users[index]['NAME'],
                    photoUrl: users[index]['PHOTO_URL'],
                    notificationToken: users[index]['NOTIFICATION_TOKEN'],
                    uid: users[index]['UID'],
                  ),
                  fromUser: currentUser,
                  imagePath: imagePath,
                ),
            itemCount: snapshot.data.documents.length,
          ),
        );
      },
    );
  }
}
