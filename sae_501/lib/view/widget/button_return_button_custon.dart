import 'package:flutter/material.dart';
/// Fonction qui crée le bouton return de base des projets
Widget customReturnButton(BuildContext context) {
  return Positioned(
    top: 35,
    left: 10,
    child: IconButton(
        icon: Image.asset(
          'assets/images/return_arrow.webp',
          width: 19,
          height: 19,
          fit: BoxFit.cover,
        ),
        onPressed: () =>  Navigator.pushNamed(context, '/')
    ),
  );
}