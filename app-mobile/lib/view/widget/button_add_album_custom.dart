import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';

/// Fonction qui crée un bouton "Ajouter" avec un gradient et un "+" en gras
Widget customAddButton(BuildContext context) {
  return Positioned(
    bottom: 75,
    right: 50,
    child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/add_album'),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ViewConstant.gradientColorLightBlue, ViewConstant.gradientColorDarkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
