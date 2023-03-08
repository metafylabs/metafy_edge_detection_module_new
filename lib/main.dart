import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:metafy_edge_detection_module/screen/image_view.dart';
import 'package:metafy_edge_detection_module/service/process_image.dart';
import 'package:metafy_edge_detection_module/service/validate_token.dart';

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
  var backgroundColor = 0x20262E;
  var buttonColor = 0xE9E8E8;
  var progressIndicatorColor = 0xE9E8E8;
  var cropperActiveIconColor = 0xFFA500;
  String cropperTitle = "Cropper";

  @override
  void initState() {
    processImage();
    super.initState();
  }

  Future<void> processImage() async {
    var res = await platform.invokeMethod(
      'sendSettings',
    );
    print("Settings--->>>> ${res}");

    String token = res["token"];
    try {
      backgroundColor = res["backgroundColor"];
      buttonColor = res["buttonColor"];
      progressIndicatorColor = res["progressIndicatorColor"];
      cropperActiveIconColor = res["cropperActiveIconColor"];
      cropperTitle = res['cropperTitle'];
    } catch (e) {
      print(e);
      rethrow;
    }

    if (ValidateToken().isValidToken(token: token)) {
      try {
        if (Platform.isAndroid) {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.camera,
          ].request();

          if (statuses.containsValue(PermissionStatus.denied)) {
            throw Exception("Permission not granted");
          }
          path = await ProcessImage()
              .getImageUrl(
                  backgroundColor: backgroundColor, buttonColor: buttonColor)
              .whenComplete(() => setState(() {}));
          print("image path flutter-------->>>>>> $path");
        } else {
          path = await ProcessImage()
              .getImageUrl(
                  backgroundColor: backgroundColor, buttonColor: buttonColor)
              .whenComplete(() => setState(() {}));
          setState(() {});
          platform.invokeMethod('callFlutterView');
        }
      } catch (e) {
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
            color: Color(progressIndicatorColor).withOpacity(1),
          ),
        ),
      );
    } else {
      return ImageView(
        path: path!,
        backgroundColor: Color(backgroundColor).withOpacity(1),
        buttonColor: Color(buttonColor).withOpacity(1),
        cropperTittle: cropperTitle,
        progressBarColor: Color(progressIndicatorColor).withOpacity(1),
        cropperActiveIconColor:Color(cropperActiveIconColor).withOpacity(1),
        onDone: (path) {
          print("cropped path----------->>>------------------------- $path");
          platform.invokeMethod('getImageUrl', {
            'url': path,
          });
        },
      );
    }
  }
}
