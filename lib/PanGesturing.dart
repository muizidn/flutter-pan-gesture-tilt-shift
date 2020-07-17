import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/FlutterNative.dart';
import 'package:myapp/ImageWithTiltShiftFilter.dart';

class PanGesturing extends StatefulWidget {
  final double width;
  final double height;

  const PanGesturing({Key key, this.width, this.height}) : super(key: key);

  @override
  _PanGesturingState createState() => _PanGesturingState();
}

class _PanGesturingState extends State<PanGesturing> {
  @override
  Widget build(BuildContext context) {
    return usingGesture();
  }

  Offset _location = Offset(0, 0);
  StreamController<File> _streamController = new StreamController();

  @override
  dispose() {
    super.dispose();
    if (_streamController != null) _streamController.close();
  }

  Widget usingGesture() {
    return StreamBuilder(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        return Container(
            decoration: BoxDecoration(color: Colors.yellow),
            width: this.widget.width,
            height: this.widget.height,
            child: Center(
                child: ImageWithTiltShiftFilter(
              image: snapshot.data,
              location: this._location,
              onLocationChange: (location) {
                setState(() {
                  this._location = location;
                });
              },
              onLocationEnd: (location, size) {
                _adjustImage(
                    location.dx / size.width, location.dy / size.height, 50.0);
              },
            )));
      },
    );
  }

  void _adjustImage(double tiltX, double tiltY, double radius) async {
    File file = await FlutterNative.adjustImage(
        "left", tiltX, tiltY, radius); // and here
    _streamController.sink.add(file);
  }
}
