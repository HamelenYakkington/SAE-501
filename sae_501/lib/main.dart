import 'package:flutter/material.dart';
import 'package:sae_501/view/acceuil.dart';
import 'package:sae_501/view/album.dart';
import 'package:sae_501/view/info.dart';

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
      '/info' : (context) => const Info(),
    },
  ));
}
