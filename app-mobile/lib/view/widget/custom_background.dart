import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';

/// Fonction qui retourne un custom contaier
Widget customContainer({
  required Widget child
}) {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/PawnBg_dark.png"),
        repeat: ImageRepeat.repeat,
      ),
    ),
      child: child
  );
}
