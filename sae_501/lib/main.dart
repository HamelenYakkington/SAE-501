// main.dart

import 'package:flutter/material.dart';
import 'camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeCameras();
  runApp(KnightSight());
}

class KnightSight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomePage',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Principale'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraPage()),
            );
          },
          child: Text('Caméra'),
        ),
      ),
    );
  }
}
