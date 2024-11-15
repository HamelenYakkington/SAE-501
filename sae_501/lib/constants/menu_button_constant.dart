import 'package:sae_501/entity/button_nav_acceuil.dart';


class MenuConstant {
  static final List<ButtonNavAcceuil> items = [
    ButtonNavAcceuil(
        text: "Album",
        imagePath: "assets/images/album_button.webp",
        route: "/album"),
    ButtonNavAcceuil(
        text: "Share Data",
        imagePath: "assets/images/share_button.webp",
        route: "/album"),
    ButtonNavAcceuil(
        text: "Receive Data",
        imagePath: "assets/images/cloud_button.webp",
        route: "/album"),
    ButtonNavAcceuil(
        text: "Info",
        imagePath: "assets/images/info_button.webp",
        route: "/info"),
  ];

}