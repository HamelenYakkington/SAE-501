import 'package:flutter/material.dart';
import 'package:sae_501/controller/deco_controller.dart';
import 'package:sae_501/constants/view_constants.dart';


/// Fonction qui crée le bouton de déconnexion dans un carré
Widget customDecoButton(BuildContext buildContext) {
  return Positioned(
    bottom: 30,
    right: 0,
    child: Container(
      decoration: BoxDecoration(
          color: ViewConstant.backgroundButton,
          borderRadius: BorderRadius.circular(8)
      ),
        child: IconButton(
          icon: Image.asset(
            'assets/images/deco_button.png',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(buildContext, '/logout');
          },
        ),
      ));
}
