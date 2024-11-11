import 'package:flutter/material.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/button_nav_acceuil_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/constants/view_constants.dart';

class ButtonNavAcceuil {
  final String text;
  final String imagePath;
  final String route;

  ButtonNavAcceuil({required this.text, required this.imagePath, required this.route});
}

class Acceuil extends StatelessWidget {
  const Acceuil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ButtonNavAcceuil> items = [
      ButtonNavAcceuil(
          text: "Album", imagePath: "assets/images/album_button.webp", route: "/album"),
      ButtonNavAcceuil(
          text: "Share Data", imagePath: "assets/images/share_button.webp", route: "/album"),
      ButtonNavAcceuil(
          text: "Receive Data", imagePath: "assets/images/cloud_button.webp", route: "/album"),
      ButtonNavAcceuil(
          text: "Info", imagePath: "assets/images/info_button.webp", route: "/album"),
    ];

    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: Container(
        color: ViewConstant.backgroundApp,
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
                    padding: const EdgeInsets.all(16.0), // Ajustez la valeur du padding selon vos besoins
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        // Utilisation des objets dans `items` pour le texte et l'image
                        final item = items[index];
                        return customButtonNavAcceuil(
                          item.text,
                          item.imagePath,
                          item.route,
                          context,
                        );
                      },
                    ),
                  ),
                ),
                customButtonPhoto(),
                customFooter(),
              ],
            ),
          ),
        ),
    );
  }
}
