import 'package:flutter/material.dart';
import 'package:sae_501/view/acceuil.dart';
import 'package:sae_501/view/album.dart';
import 'package:sae_501/view/info.dart';
import 'package:sae_501/view/camera.dart';
import 'package:sae_501/view/test.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => const Acceuil(),
      '/album': (context) => const Album(),
      '/add_album' : (context) => const Acceuil(),
      '/info' : (context) => const Info(),
      // '/camera' : (context) => Camera(),
      '/camera' : (context) => TestCamera(),
    },
  ));
}
