import 'package:flutter/material.dart';
import 'package:sae_501/controller/deco_controller.dart';
import 'package:sae_501/constants/view_constants.dart';


/// Fonction qui crée le bouton de déconnexion dans un carré
Widget customDecoButton(BuildContext buildContext) {
  return Positioned(
    top: 35,
    left: 10,
    child: Container(
      decoration: BoxDecoration(
          color: ViewConstant.backgroundButton,
          borderRadius: BorderRadius.circular(8)
      ),
        child: IconButton(
          icon: Image.asset(
            'assets/images/deco_button.webp',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
          onPressed: () {
            deco(buildContext);
          },
        ),
      ));
}
