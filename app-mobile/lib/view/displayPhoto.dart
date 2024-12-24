import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/button_exit_custom.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final List<Map<String, dynamic>> yoloResults;

  const DisplayPictureScreen({
    required this.imagePath,
    required this.yoloResults,
  });

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    print("Display Rectangle 2");
    if (widget.yoloResults.isEmpty) return [];
    final imageFile = File(widget.imagePath);
    final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    double imageWidth = image.width.toDouble();
    double imageHeight = image.height.toDouble();

    double factorX = screen.width / imageWidth;
    double factorY = screen.height / imageHeight;

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return widget.yoloResults.map((result) {
      double objectX = result["box"][0] * factorX;
      double objectY = result["box"][1] * factorY;
      double objectWidth = (result["box"][2] - result["box"][0]) * factorX;
      double objectHeight = (result["box"][3] - result["box"][1]) * factorY;
      return Positioned(
        left: objectX,
        top: objectY,
        width: objectWidth,
        height: objectHeight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(2)}%",
            style: TextStyle(
              background: Paint()
                ..color = colorPick,
              color: const Color.fromARGB(255, 115, 0, 255),
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: Container(
        color: ViewConstant.backgroundApp,
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(fit: StackFit.expand, children: [
                              // Affichez l'image
                              Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.contain,
                              ),
                              ...displayBoxesAroundRecognizedObjects(size),
                            ]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            customExitButton(context),
          ],
        ),
      ),
    );
  }
}
