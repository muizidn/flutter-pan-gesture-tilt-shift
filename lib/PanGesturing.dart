import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/FlutterNative.dart';

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
              child: GestureDetector(
                  onPanStart: (details) {
                    print("Gesture Start ${details.localPosition}");
                    setState(() {
                      _location = details.localPosition;
                    });
                  },
                  onPanUpdate: (details) {
                    print("Gesture Update ${details.localPosition}");
                    setState(() {
                      _location = details.localPosition;
                    });
                  },
                  onPanEnd: (details) {
                    print("Gesture End");
                    setState(() {
                      _adjustImage(this._location.dx, this._location.dy, 50.0);
                    });
                  },
                  child: Stack(
                    children: [
                      snapshot.data != null
                          ? Image.file(snapshot.data)
                          : Image.asset("images/taken_by_app.jpg"),
                      Positioned(
                        height: this.widget.height / 4,
                        width: this.widget.width / 4,
                        top: _location.dy - ((this.widget.height / 4) / 2),
                        left: _location.dx - ((this.widget.width / 4) / 2),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.red),
                        ),
                      )
                    ],
                  )),
            ));
      },
    );
  }

  void _adjustImage(double tiltX, double tiltY, double radius) async {
    File file =
        await FlutterNative.adjustImage("taken_by_app", tiltX, tiltY, radius);
    _streamController.sink.add(file);
  }
}
