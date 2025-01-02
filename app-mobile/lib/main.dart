import 'package:flutter/material.dart';
import 'package:sae_501/view/acceuil.dart';
import 'package:sae_501/view/historique.dart';
import 'package:sae_501/view/register.dart';
import 'package:sae_501/view/info.dart';
import 'package:sae_501/view/camera.dart';
import 'package:sae_501/view/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => Acceuil(),
        '/add_album': (context) => Acceuil(),
        '/info': (context) => Info(),
        '/camera': (context) => const Camera(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/historique': (context) => const Historique(),
      },
    );
  }
}
