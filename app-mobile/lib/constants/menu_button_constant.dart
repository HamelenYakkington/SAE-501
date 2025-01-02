import 'package:sae_501/entity/button_nav_acceuil.dart';


class MenuConstant {
  static final List<ButtonNavAcceuil> items = [
    ButtonNavAcceuil(
        text: "History",
        imagePath: "assets/images/history.webp",
        route: "/historique"),
    ButtonNavAcceuil(
        text: "Receive Data",
        imagePath: "assets/images/cloud_button.webp",
        route: "/camera"),
    ButtonNavAcceuil(
        text: "Info",
        imagePath: "assets/images/info_button.webp",
        route: "/info"),
    ButtonNavAcceuil(
        text: "LogOut",
        imagePath: "assets/images/deco_button_menu.webp",
        route: "/logout"),
  ];

}