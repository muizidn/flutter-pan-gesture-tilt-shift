import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';

typedef OnLocationChange = void Function(Offset location);
typedef OnLocationEnd = void Function(Offset location, Size size);

class GesturableImage extends StatefulWidget {
  final File image;
  final Offset location;
  final OnLocationChange onLocationChange;
  final OnLocationEnd onLocationEnd;
  const GesturableImage(
      {Key key,
      this.image,
      this.location,
      this.onLocationChange,
      this.onLocationEnd})
      : super(key: key);

  @override
  _GesturableImage createState() => _GesturableImage();
}

class _GesturableImage extends State<GesturableImage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        print("Gesture start at ${details.localPosition}");
        print("Widget size ${rectGetter.getRect().size}");
        this.widget.onLocationChange(details.localPosition);
      },
      onPanUpdate: (details) {
        print("Widget size ${rectGetter.getRect().size}");
        print("Gesture update at ${details.localPosition}");
        this.widget.onLocationChange(details.localPosition);
      },
      onPanEnd: (details) {
        print("Widget size ${rectGetter.getRect().size}");
        print(
            "Gesture end normalized X ${this.widget.location.dx / rectGetter.getRect().size.width}");
        print(
            "Gesture end normalized Y ${this.widget.location.dy / rectGetter.getRect().size.height}");
        this
            .widget
            .onLocationEnd(this.widget.location, rectGetter.getRect().size);
      },
      child: Stack(
        children: [
          createImage(),
          Positioned(
            height: 50,
            width: 50,
            top: this.widget.location.dy - (50 / 2),
            left: this.widget.location.dx - (50 / 2),
            child: Container(
                decoration: const BoxDecoration(
                    border: Border(
              top: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
              left: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
              right: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
              bottom: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
            ))),
          )
        ],
      ),
    );
  }

  RectGetter rectGetter;

  Widget createImage() {
    Widget w;
    if (this.widget.image != null) {
      w = Image.file(
        this.widget.image,
        gaplessPlayback: true,
        fit: BoxFit.contain,
      );
    } else {
      w = Image.asset(
        "images/left.jpg",
        gaplessPlayback: true,
        fit: BoxFit.contain,
      );
    }
    rectGetter = new RectGetter.defaultKey(
      child: w,
    );
    return rectGetter;
  }
}
