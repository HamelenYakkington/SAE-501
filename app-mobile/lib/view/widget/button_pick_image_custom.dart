import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';

/// Fonction qui crée le bouton permettant le chargement d'image de la galerie de l'utilisateur
Widget customPickImage(VoidCallback? onTap) {
  return Positioned(
    bottom: 0,
    right: 0,
    child: Container(
      decoration: BoxDecoration(
        color: ViewConstant.backgroundButton,
        borderRadius: BorderRadius.circular(8)
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
          fixedSize: Size(30, 30),
        ),
        child: Icon(
          Icons.image,
          color: ViewConstant.GradientColorLightBlue,
          size: 30,
        ),
      ),
    ),
  );
}
