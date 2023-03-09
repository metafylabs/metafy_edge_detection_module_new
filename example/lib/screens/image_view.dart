import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';

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
  bool isLoading = false;
  String? _path;
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: widget.backgroundColor,
              title: Text(widget.cropperTittle),
            ),
            backgroundColor: widget.backgroundColor,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.backgroundColor,
              child: Center(
                child: CircularProgressIndicator(
                  color: widget.progressBarColor,
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: widget.backgroundColor,
              title: Text(widget.cropperTittle),
            ),
            backgroundColor: widget.backgroundColor,
            body: Center(
              child: CropImage(
                controller: controller,
                image: Image.file(File(_path!)),
                paddingSize: 25.0,
                alwaysMove: true,
              ),
            ),
            bottomNavigationBar: _buildButtons(),
          );
  }

  Widget _buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.rotation = CropRotation.up;
              controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              controller.aspectRatio = 1.0;
            },
            color: widget.buttonColor,
          ),
          IconButton(
            icon: const Icon(Icons.aspect_ratio),
            onPressed: _aspectRatios,
            color: widget.buttonColor,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
            onPressed: _rotateLeft,
            color: widget.buttonColor,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
            onPressed: _rotateRight,
            color: widget.buttonColor,
          ),
          TextButton(
            onPressed: _finished,
            child: Text(
              'Done',
              style: TextStyle(color: widget.buttonColor),
            ),
          ),
        ],
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            // special case: no aspect ratio
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> _finished() async {
    setState(() {
      isLoading = true;
    });
    final newFile = await File(_path!).copy(generateFilePath());
    final bitmap = await controller.croppedBitmap();
    var data = await bitmap.toByteData(format: ImageByteFormat.png);
    var bytes = data!.buffer.asUint8List();
    var path = await File(newFile.path).writeAsBytes(bytes);

    setState(() {
      isLoading = false;
    });
    widget.onDone(path.path);
    return;
  }
}
