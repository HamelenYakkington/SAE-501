import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sae_501/object_detection.dart';
import 'dart:io' show Platform;
import 'package:sae_501/view/acceuil.dart';
import 'package:sae_501/view/album.dart';

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
    },
  ));
}
