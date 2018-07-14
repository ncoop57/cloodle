import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

class CloodleRoute extends StatelessWidget {
  final String imageName;

  CloodleRoute({this.imageName});

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
              alignment: Alignment.centerRight,
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
          new IconButton(
            icon: const Icon(Icons.wb_cloudy),
            color: Colors.blue,
            onPressed: () => print("Enter Answer"),
          ),
        ],
      ),
    );
  }
}
