import 'package:flutter/material.dart';

/// Fonction qui crée le header de base des projets
Widget customHeader(String text, String imagePath) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 30),
      Image.asset(
        imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
      const SizedBox(height: 10),
      Text(
        text,
        style: const TextStyle(
          fontFamily: 'Do Hyeon',
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w900,
          fontSize: 32,
          height: 40 / 32,
          color: Colors.white,
        ),
      ),
    ],
  );
}



