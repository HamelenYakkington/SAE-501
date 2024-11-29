import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Fonction qui crée le footer de base des projets
Widget customFooter() {
  String currentYear = DateFormat('yyyy').format(DateTime.now());

  return Container(
    color: Colors.black,
    width: double.infinity,
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Text(
        '© $currentYear tous droits réservés',
        style: const TextStyle(
          fontFamily: 'Courier Prime',
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 13 / 12,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}



