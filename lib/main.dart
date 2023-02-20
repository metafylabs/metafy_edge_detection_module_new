import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String path = "";

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

    // String cropTitle = res["CropTitle"];
    // String cropBlackAndWhiteTitle = res["CropBlackAndWhiteTitle"];

    // String path = await ProcessImage().getImageIos(
    //     scanTitle: scanTitle,
    //     cropTitle: cropTitle,
    //     cropBlackAndWhiteTitle: cropBlackAndWhiteTitle);

    if (ValidateToken().isValidToken(token: token)) {
      path = await ProcessImage().getImageAndroid();
    } else {
      print("Error : Invalid access token, path Url: $path");
    }

    platform.invokeMethod('getImageUrl', {
      'url': path,
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}
