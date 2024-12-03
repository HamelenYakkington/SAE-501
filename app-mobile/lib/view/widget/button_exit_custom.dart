import 'package:flutter/material.dart';
/// Fonction qui crée le bouton return de base des projets
Widget customExitButton(BuildContext context) {
  return Positioned(
    top: 35,
    right: 10,
    child: IconButton(
        icon: Image.asset(
          'assets/images/exit_x.webp',
          width: 19,
          height: 19,
          fit: BoxFit.cover,
        ),
        onPressed: () =>  Navigator.pushNamed(context, '/')
    ),
  );
}