import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';

class ProcessImage {
  Future<String> getImageIos(
      {@required String? scanTitle,
      @required String? cropTitle,
      @required String? cropBlackAndWhiteTitle}) async {
    String imagePath = '';

    // bool isCameraGranted = await Permission.camera.request().isGranted;
    // if (!isCameraGranted) {
    //   isCameraGranted =
    //       await Permission.camera.request() == PermissionStatus.granted;
    // }

    // if (!isCameraGranted) {
    //   return imagePath;
    // }

    // imagePath = join((await getApplicationSupportDirectory()).path,
    //     "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    try {
      // await EdgeDetection.detectEdge(
      //   imagePath,
      //   canUseGallery: true,
      //   androidScanTitle: scanTitle ?? 'Scanning',
      //   androidCropTitle: cropTitle ?? 'Crop',
      //   androidCropBlackWhiteTitle: cropBlackAndWhiteTitle ?? 'Black White',
      //   androidCropReset: 'Reset',
      // );
      print('image path------->>>>> $imagePath');
      return imagePath;
    } catch (e) {
      print("image path error  $e");
      return imagePath;
    }
  }

  Future<String> getImageAndroid(
      {required var backgroundColor, required var buttonColor}) async {
    String path = "";
    try {
      List<String> pictures = [];
      try {
        pictures = await CunningDocumentScanner.getPictures(
                buttonColor, backgroundColor) ??
            [];

        print(pictures);
      } catch (exception) {
        print(exception);
        rethrow;
        // Handle exception here
      }
      path = pictures.first.toString();

      print('----------->>>>>>>>>> image path $path');
    } catch (e) {
      print(e);
      rethrow;
    }
    return path;
  }
}
