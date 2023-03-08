import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';

class ImageView extends StatefulWidget {
  const ImageView(
      {Key? key,
      required this.path,
      required this.onDone,
      required this.backgroundColor,
      required this.buttonColor,
      required this.progressBarColor,
      required this.cropperActiveIconColor,
      required this.cropperTittle})
      : super(key: key);
  final String path;
  final String cropperTittle;
  final Function onDone;

  final Color? backgroundColor;
  final Color? buttonColor;
  final Color? progressBarColor;
  final Color? cropperActiveIconColor;

  @override
  ImageViewState createState() => ImageViewState();
}

class ImageViewState extends State<ImageView> {
  String? _path;
  @override
  void initState() {
    setState(() {
      _path = widget.path;
    });
    cropImage();
    super.initState();
  }

  String generateFilePath() {
    Random random = Random();
    int randomNumber = random.nextInt(1000000);

    var splitPath = _path.toString().trim().split('/');
    splitPath.removeLast();
    splitPath.add('rotatedImage$randomNumber.jpg');
    String newPath = '';
    splitPath.forEach((element) {
      newPath = '$newPath/$element';
    });
    return newPath.substring(1);
  }

  void rotateImage() async {
    try {
      final newFile = await File(_path!).copy(generateFilePath());

      Uint8List imageBytes = await newFile.readAsBytes();

      final originalImage = img.decodeImage(imageBytes);

      img.Image fixedImage;
      fixedImage = img.copyRotate(originalImage!, angle: 90);

      final fixedFile =
          await newFile.writeAsBytes(img.encodeJpg(fixedImage), flush: true);

      setState(() {
        _path = fixedFile.path;
      });
    } catch (e) {
      rethrow;
    }
  }

  void cropImage() async {
    print("call crop image--------->>>>>>");
    final newFile = await File(_path!).copy(generateFilePath());

    var croppedFile = await ImageCropper().cropImage(
        sourcePath: newFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: widget.cropperTittle,
              toolbarColor: widget.backgroundColor,
              toolbarWidgetColor: widget.buttonColor,
              activeControlsWidgetColor: widget.cropperActiveIconColor,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: widget.cropperTittle,
          ),
        ]);
    print("cropImage-------->>>>> $croppedFile");
    widget.onDone(croppedFile!.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          color: widget.progressBarColor,
        ),
      ),
    );
  }
}
