import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:myapp/PanGesturing.dart';

void main() => runApp(PanGestureApp());

class PanGestureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) {
          if (kIsWeb) {
            return WebScreen();
          } else {
            return AppScreen();
          }
        },
      },
    );
  }
}

class WebScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: PanGesturing(
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}

class AppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: PanGesturing(
          width: 640 / 2 - 50,
          height: 1136 / 2 - 50,
        ),
      ),
    );
  }
}
