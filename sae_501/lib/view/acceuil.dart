import 'package:flutter/material.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/button_nav_acceuil_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/constants/menu_button_constant.dart';



class Acceuil extends StatelessWidget {
  const Acceuil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: MenuConstant.items.length,
                      itemBuilder: (context, index) {
                        final item = MenuConstant.items[index];
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
