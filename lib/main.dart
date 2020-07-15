import 'package:flutter/material.dart';
import 'package:myapp/PanGesturing.dart';

void main() => runApp(PanGestureApp());

class PanGestureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => MainScreen(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: PanGesturing(
        width: 200,
        height: 200,
      ),
    );
  }
}
