import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class Camera extends StatefulWidget {
  @override
  _CustomCameraViewState createState() => _CustomCameraViewState();
}

class _CustomCameraViewState extends State<Camera> {
  late List<CameraDescription> cameras;
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final albumDirectory = Directory(join(directory.path, 'Album_App'));
      if (!await albumDirectory.exists()) {
        await albumDirectory.create(recursive: true);
      }
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = join(albumDirectory.path, fileName);

      File(image.path).copy(filePath);

      print("Photo sauvegardée dans: $filePath");
    } catch (e) {
      print("Erreur lors de la capture de l'image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caméra personnalisée")),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _takePhoto,
                      child: Icon(Icons.camera_alt, size: 40),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
