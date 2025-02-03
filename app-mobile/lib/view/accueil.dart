import 'package:flutter/material.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/widget/custom_background.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/grid_builder_custom.dart';
import 'package:sae_501/constants/menu_button_constant.dart';
import 'package:sae_501/view/widget/button_nav_acceuil_custom.dart';

class Accueil extends StatefulWidget {

  const Accueil({Key? key}) : super(key: key);

  @override
  AccueilState createState() => AccueilState();
}

class AccueilState extends State<Accueil> {

  @override
  void initState() {
    super.initState();
    checkConnexionToken(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: Stack(
        children: [
          customContainer(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 25),
                  customHeader(
                      'KnightSight', 'assets/images/chess_lense_logo.webp'),
                  const SizedBox(height: 25),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: gridBuilderCustom(customButtonNavAcceuil, MenuConstant.items, context),
                    ),
                  ),
                  customButtonPhoto(context: context),
                  customFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
