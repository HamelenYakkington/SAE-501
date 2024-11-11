import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';

/// Fonction qui crée un bouton nav photo avec un demi-cercle au-dessus
Widget customButtonPhoto() {
  return SizedBox(
    width: double.infinity,
    height: 120,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: ViewConstant.backgroundButton,
            height: 20,
            width: double.infinity,
          ),
        ),
        Positioned(
          top:
              55,
          child: GestureDetector(
            onTap: () {
              print("Cercle cliqué");
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: ViewConstant.backgroundButton,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Align(
                    alignment: Alignment
                        .topCenter,
                    child: Image.asset(
                      height: 50,
                      'assets/images/camera_button.webp',
                      fit: BoxFit
                          .cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
