import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:cloodle/routes/friends_list_route.dart';
import 'package:cloodle/models/user.dart';
import 'package:cloodle/models/cloodle_painter.dart';

class EditorRoute extends StatefulWidget {
  final User currentUser;
  final String imagePath;

  EditorRoute({this.imagePath, this.currentUser});

  @override
  EditorRouteState createState() {
    return new EditorRouteState();
  }
}

class EditorRouteState extends State<EditorRoute>
    with TickerProviderStateMixin {
  AnimationController controller;
  List<Offset> points = <Offset>[];
  Color color = Colors.blue;
  StrokeCap strokeCap = StrokeCap.round;
  double strokeWidth = 5.0;
  List<CloodlePainter> painters = <CloodlePainter>[];
  Future<ui.Image> cloodle;

  @override
  void initState() {
    super.initState();
    this.cloodle = _loadImage();
    controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<ui.Image> _loadImage() async {
    var assetImage = new ExactAssetImage(widget.imagePath);
    var key = await assetImage.obtainKey(new ImageConfiguration());

    final ByteData data = await key.bundle.load(key.name);
    if (data == null) throw 'Unable to read data';
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    // add additional checking for number of frames etc here
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox object = context.findRenderObject();
              Offset localPosition =
                  object.globalToLocal(details.globalPosition);
              points = new List.from(points);
              points.add(localPosition);
            });
          },
          onPanEnd: (DragEndDetails details) => points.add(null),
          child: new FutureBuilder<ui.Image>(
            future: this.cloodle,
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Image loading...');
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else
                    // ImageCanvasDrawer would be a (most likely) statless widget
                    // that actually makes the CustomPaint etc
                    return CustomPaint(
                      painter: CloodlePainter(
                          image: snapshot.data,
                          points: points,
                          color: color,
                          strokeCap: strokeCap,
                          strokeWidth: strokeWidth,
                          painters: painters),
                      size: Size.infinite,
                    );
              }
            },
          ),
        ),
      ),
      // floatingActionButton:
      //     Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      //   Container(
      //     height: 70.0,
      //     width: 56.0,
      //     alignment: FractionalOffset.topCenter,
      //     child: ScaleTransition(
      //       scale: CurvedAnimation(
      //         parent: controller,
      //         curve: Interval(0.0, 1.0 - 0 / 3 / 2.0, curve: Curves.easeOut),
      //       ),
      //       child: FloatingActionButton(
      //         mini: true,
      //         child: Icon(Icons.clear),
      //         onPressed: () {
      //           points.clear();
      //           for (Painter painter in painters) {
      //             painter.points.clear();
      //           }
      //         },
      //       ),
      //     ),
      //   ),
      //   Container(
      //     height: 70.0,
      //     width: 56.0,
      //     alignment: FractionalOffset.topCenter,
      //     child: ScaleTransition(
      //       scale: CurvedAnimation(
      //         parent: controller,
      //         curve: Interval(0.0, 1.0 - 1 / 3 / 2.0, curve: Curves.easeOut),
      //       ),
      //       child: FloatingActionButton(
      //         mini: true,
      //         child: Icon(Icons.lens),
      //         onPressed: () async {
      //           double temp;
      //           temp = await showDialog(
      //               context: context, builder: (context) => WidthDialog(strokeWidth: strokeWidth));
      //           if (temp != null) {
      //             setState(() {
      //               painters.add(Painter(
      //                   points: points.toList(),
      //                   color: color,
      //                   strokeCap: strokeCap,
      //                   strokeWidth: strokeWidth));
      //               points.clear();
      //               strokeWidth = temp;
      //             });
      //           }
      //         },
      //       ),
      //     ),
      //   ),
      //   Container(
      //       height: 70.0,
      //       width: 56.0,
      //       alignment: FractionalOffset.topCenter,
      //       child: ScaleTransition(
      //           scale: CurvedAnimation(
      //             parent: controller,
      //             curve:
      //                 Interval(0.0, 1.0 - 2 / 3 / 2.0, curve: Curves.easeOut),
      //           ),
      //           child: FloatingActionButton(
      //               mini: true,
      //               child: Icon(Icons.color_lens),
      //               onPressed: () async {
      //                 Color temp;
      //                 temp = await showDialog(
      //                     context: context,
      //                     builder: (context) => ColorDialog());
      //                 if (temp != null) {
      //                   setState(() {
      //                     painters.add(Painter(
      //                         points: points.toList(),
      //                         color: color,
      //                         strokeCap: strokeCap,
      //                         strokeWidth: strokeWidth));
      //                     points.clear();
      //                     color = temp;
      //                   });
      //                 }
      //               }))),
      //   FloatingActionButton(
      //     child: AnimatedBuilder(
      //       animation: controller,
      //       builder: (BuildContext context, Widget child) {
      //         return Transform(
      //           transform: Matrix4.rotationZ(controller.value * 0.5 * math.pi),
      //           alignment: FractionalOffset.center,
      //           child: Icon(Icons.brush),
      //         );
      //       },
      //     ),
      //     onPressed: () {
      //       if (controller.isDismissed) {
      //         controller.forward();
      //       } else {
      //         controller.reverse();
      //       }
      //     },
      //   ),
      // ]),
    );
  }
}

// class EditorRouteState extends State<EditorRoute>
//     with AutomaticKeepAliveClientMixin<EditorRoute> {
//   List<Offset> _points = <Offset>[];
//   Future<ui.Image> cloodle;

//   @override
//   void initState() {
//     super.initState();
//     this.cloodle = _loadImage();
//   }

//   Future<ui.Image> _loadImage() async {
//     var assetImage = new ExactAssetImage(widget.imagePath);
//     var key = await assetImage.obtainKey(new ImageConfiguration());

//     final ByteData data = await key.bundle.load(key.name);
//     if (data == null) throw 'Unable to read data';
//     var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
//     // add additional checking for number of frames etc here
//     var frame = await codec.getNextFrame();
//     return frame.image;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//         title: const Text('Cloodle Editors'),
//       ),
//       body: new Container(
//         child: new GestureDetector(
//           onPanUpdate: (DragUpdateDetails details) {
//             setState(() {
//               RenderBox object = context.findRenderObject();
//               Offset _localPosition =
//                   object.globalToLocal(details.globalPosition);
//               _points = new List.from(_points)..add(_localPosition);
//             });
//           },
//           onPanEnd: (DragEndDetails details) => _points.add(null),
//           child: new FutureBuilder<ui.Image>(
//             future: this.cloodle,
//             builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
//               switch (snapshot.connectionState) {
//                 case ConnectionState.waiting:
//                   return new Text('Image loading...');
//                 default:
//                   if (snapshot.hasError)
//                     return new Text('Error: ${snapshot.error}');
//                   else
//                     // ImageCanvasDrawer would be a (most likely) statless widget
//                     // that actually makes the CustomPaint etc
//                     return new CustomPaint(
//                       painter: new CloodlePainter(
//                         image: snapshot.data,
//                         points: _points,
//                       ),
//                       size: Size.infinite,
//                     );
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return new Scaffold(
//   //     appBar: new AppBar(
//   //       title: const Text('Cloodle Editors'),
//   //     ),
//   //     body: new Column(
//   //       children: [
//   //         new Expanded(
//   //           child: new Align(
//   //             alignment: Alignment.centerRight,
//   //             child: widget.imagePath == null
//   //                 ? null
//   //                 : new Image.file(new File(widget.imagePath)),
//   //           ),
//   //         ),
//   //         new IconButton(
//   //           icon: const Icon(Icons.wb_cloudy),
//   //           color: Colors.blue,
//   //           onPressed: () => _handleSendCloodle(context),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   void _handleSendCloodle(BuildContext context) {
//     Navigator.of(context).push(
//       new MaterialPageRoute<void>(
//         builder: (BuildContext context) {
//           return new FriendsListRoute(
//               imagePath: widget.imagePath, currentUser: widget.currentUser);
//         },
//       ),
//     );
//   }

//   @override
//   // TODO: implement wantKeepAlive
//   bool get wantKeepAlive => true;
// }
