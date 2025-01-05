import 'package:flutter/material.dart';

List<Widget> returnBoxes(Size screen,
    List<Map<String, dynamic>> yoloResults,
    double factorX,
    double factorY ) {
  Color colorPick = const Color.fromARGB(255, 50, 233, 30);
  return yoloResults.map((result) {
    double objectX = result["box"][0] * factorX;
    double objectY = result["box"][1] * factorY;
    double objectWidth = (result["box"][2] - result["box"][0]) * factorX;
    double objectHeight = (result["box"][3] - result["box"][1]) * factorY;

    return Stack(
      children: [
        // Label above the rectangle
        Positioned(
          left: objectX,
          top: objectY - 20, // Position above the rectangle
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(2)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: const Color.fromARGB(255, 115, 0, 255),
              fontSize: 14.0,
            ),
          ),
        ),
        // Rectangle itself
        Positioned(
          left: objectX,
          top: objectY,
          width: objectWidth,
          height: objectHeight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.pink, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }).toList();
}