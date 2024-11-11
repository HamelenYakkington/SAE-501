import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';

/// Fonction qui crée un button carré avec une image et un texte en dessous
Widget customButtonNavAcceuil(String text, String imagePath, String page, BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, page);
    },
    child: Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: ViewConstant.backgroundButton,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
