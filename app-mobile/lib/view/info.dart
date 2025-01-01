import 'package:flutter/material.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/view/widget/button_deconnexion_custom.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/constants/info_constants.dart';
import 'package:sae_501/view/widget/button_return_custom.dart';

class Info extends StatefulWidget {
  @override
  _Info createState() => _Info();
}

class _Info  extends State<Info> {

  @override
  void initState() {
    super.initState();
    checkConnexionToken(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: Container(
        color: ViewConstant.backgroundApp,
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 25),
                    customHeader('Info', 'assets/images/info_button.webp'),
                    const SizedBox(height: 25),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: InfoConstant.infos.length,
                          itemBuilder: (context, index) {
                            final article = InfoConstant.infos[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      article.content,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    customButtonPhoto(context: context),
                    customFooter(),
                  ],
                ),
              ),
            ),
            customReturnButton(context),
            customDecoButton(context),
          ],
        ),
      ),
    );
  }
}
