import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as img;

class ImageView extends StatefulWidget {
  const ImageView(
      {Key? key,
      required this.path,
      required this.onDone,
      required this.backgroundColor,
      required this.iconColor,
      required this.borderColor})
      : super(key: key);
  final String path;
  final Function onDone;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

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
      generateFilePath();
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: Image.file(
                  File(_path!),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        rotateImage();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(
                            side: BorderSide(color: widget.borderColor!)),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Icon(
                        Icons.rotate_90_degrees_cw_rounded,
                        size: 30,
                        color: widget.iconColor,
                      )),
                  ElevatedButton(
                      onPressed: () => widget.onDone(_path),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(
                            side: BorderSide(color: widget.borderColor!)),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Icon(
                        Icons.done,
                        size: 30,
                        color: widget.iconColor,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
