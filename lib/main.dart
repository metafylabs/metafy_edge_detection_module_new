import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metafy_edge_detection_module/screen/image_view.dart';
import 'package:metafy_edge_detection_module/service/process_image.dart';
import 'package:metafy_edge_detection_module/service/validate_token.dart';

import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraAnimation(),
    );
  }
}

class CameraAnimation extends StatefulWidget {
  const CameraAnimation({
    Key? key,
  }) : super(key: key);

  @override
  State<CameraAnimation> createState() => _CameraAnimationState();
}

class _CameraAnimationState extends State<CameraAnimation> {
  static const platform =
      MethodChannel('com.example.metafy_edge_detection_module');

  String? path;
  var backgroundColor;
  var buttonColor;
  var progressIndicatorColor;

  @override
  void initState() {
    processImage();
    super.initState();
  }

  processImage() async {
    var res = await platform.invokeMethod(
      'sendSettings',
    );

    String token = res["token"];
    try {
      backgroundColor = res["backgroundColor"];
      buttonColor = res["buttonColor"];
      progressIndicatorColor = res["progressIndicatorColor"];
    } catch (e) {
      print(e);
      rethrow;
    }

    if (ValidateToken().isValidToken(token: token)) {
      try {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.camera,
        ].request();
        if (statuses.containsValue(PermissionStatus.denied)) {
          throw Exception("Permission not granted");
        }

        path = await ProcessImage()
            .getImageAndroid(
                backgroundColor: backgroundColor, buttonColor: buttonColor)
            .whenComplete(() => setState(() {}));
      } catch (e) {
        print("Error : Image processing error : $e");
        rethrow;
      }
    } else {
      throw Exception("Invalid access token");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(backgroundColor).withOpacity(1),
        child: Center(
          child: CircularProgressIndicator(
            color: progressIndicatorColor,
          ),
        ),
      );
    } else {
      return ImageView(
        path: path!,
        backgroundColor: Color(backgroundColor).withOpacity(1),
        buttonColor: Color(buttonColor).withOpacity(1),
        onDone: (path) {
          platform.invokeMethod('getImageUrl', {
            'url': path,
          });
        },
      );
    }
  }
}
