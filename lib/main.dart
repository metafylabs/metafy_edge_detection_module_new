import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metafy_edge_detection_module/screen/image_view.dart';
import 'package:metafy_edge_detection_module/service/process_image.dart';
import 'package:metafy_edge_detection_module/service/validate_token.dart';

import 'package:image/image.dart' as img;

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
  Color? backgroundColor = Colors.black;
  Color? iconColor = Colors.white;
  Color? borderColor = Colors.white;
  Color? progressIndicatorColor = Colors.white;

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
    backgroundColor = res["backgroundColor"];
    iconColor = res["iconColor"];
    borderColor = res["borderColor"];
    progressIndicatorColor = res["progressIndicatorColor"];

    // String cropTitle = res["CropTitle"];
    // String cropBlackAndWhiteTitle = res["CropBlackAndWhiteTitle"];

    // String path = await ProcessImage().getImageIos(
    //     scanTitle: scanTitle,
    //     cropTitle: cropTitle,
    //     cropBlackAndWhiteTitle: cropBlackAndWhiteTitle);

    if (ValidateToken().isValidToken(token: token)) {
      path = await ProcessImage()
          .getImageAndroid()
          .whenComplete(() => setState(() {}));
    } else {
      print("Error : Invalid access token, path Url: $path");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor,
        child: Center(
          child: CircularProgressIndicator(
            color: progressIndicatorColor,
          ),
        ),
      );
    } else {
      return ImageView(
        path: path!,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        iconColor: iconColor,
        onDone: (path) {
          platform.invokeMethod('getImageUrl', {
            'url': path,
          });
          print("new path ---->>>>>>> ${path.toString()}");
        },
      );
    }
  }
}
