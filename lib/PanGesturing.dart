import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

  GestureDetector usingGesture() {
    return GestureDetector(
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
        child: Container(
            decoration: BoxDecoration(color: Colors.yellow),
            width: this.widget.width,
            height: this.widget.height,
            child: Stack(
              children: [
                Center(
                  child: Image(image: AssetImage('images/taken_by_app.jpg')),
                ),
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
            )));
  }

  Draggable usingDraggable() {
    return Draggable(
      child: Container(
        width: 50,
        height: 50,
        color: Colors.blue,
        child: Center(
          child: Text(
            "Drag",
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
      ),
      feedback: Container(
        child: Center(
          child: Text(
            "Drag",
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        color: Colors.red[800],
        width: 50,
        height: 50,
      ),
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        print("draggable canceled $offset");
      },
    );
  }
}
