import 'dart:io';

import 'package:flutter/services.dart';

class FlutterNative {
  static const MethodChannel _channel =
      const MethodChannel('flutter_native_image');

  static Future<File> adjustImage(
      String filename, double tiltX, double tiltY, double radius) async {
    var file = await _channel.invokeMethod("adjustImage", {
      "file_name": filename,
      "tiltX": tiltX,
      "tiltY": tiltY,
      "tiltRadius": radius
    });

    print("#=> GOT FILE $file");

    return new File(file);
  }
}
