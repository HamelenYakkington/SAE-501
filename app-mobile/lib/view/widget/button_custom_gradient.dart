import 'package:flutter/material.dart';

/// Fonction qui crée un bouton avec un gradient personnalisable, un texte et une couleur de texte
Widget customGradientButton({
  required BuildContext context,
  required String text,
  required VoidCallback onPressed,
  required Gradient gradient, // Pass the gradient as a parameter
  Color textColor = Colors.white, // Optional parameter for text color, default is white
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: textColor, // Use the customizable text color
          ),
        ),
      ),
    ),
  );
}