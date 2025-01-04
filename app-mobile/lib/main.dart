import 'package:flutter/material.dart';
import 'package:sae_501/view/acceuil.dart';
import 'package:sae_501/view/historique.dart';
import 'package:sae_501/view/logout.dart';
import 'package:sae_501/view/receivedata.dart';
import 'package:sae_501/view/register.dart';
import 'package:sae_501/view/info.dart';
import 'package:sae_501/view/camera.dart';
import 'package:sae_501/view/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const Acceuil(),
        '/receive': (context) => const ReceiveData(),
        '/info': (context) => const Info(),
        '/camera': (context) => const Camera(),
        '/login': (context) => const Login(),
        '/logout': (context) => const LogOut(),
        '/register': (context) => const Register(),
        '/historique': (context) => const Historique(),
      },
    );
  }
}
