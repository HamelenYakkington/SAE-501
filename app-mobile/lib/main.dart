import 'package:flutter/material.dart';
import 'package:sae_501/view/acceuil.dart';
import 'package:sae_501/view/album.dart';
import 'package:sae_501/view/register.dart';
import 'package:sae_501/view/sub album.dart';
import 'package:sae_501/view/info.dart';
import 'package:sae_501/view/camera.dart';
import 'package:sae_501/view/login.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    ),
    initialRoute: '/login',
    routes: {
      '/': (context) => const Acceuil(),
      '/album': (context) => const Album(),
      '/sub_album': (context) => const SubAlbum(),
      '/add_album' : (context) => const Acceuil(),
      '/info' : (context) => const Info(),
      '/camera' : (context) => const Camera(),
      '/login' : (context) => Login(),
      '/register' : (context) => Register(),
    },
  ));
}
