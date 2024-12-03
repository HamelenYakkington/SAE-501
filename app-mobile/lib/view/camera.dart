import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/button_exit_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';

class Camera extends StatefulWidget {
  @override
  _CustomCameraViewState createState() => _CustomCameraViewState();
}

class _CustomCameraViewState extends State<Camera> {
  late List<CameraDescription> cameras;
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final String _imagePath = "";

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

    } catch (e) {
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: ViewConstant.backgroundScalfold,
    body: Container(
      color: ViewConstant.backgroundApp,
      child: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Column(
                        children: [
                          // Intégrer la vue caméra
                          Expanded(
                            child: FutureBuilder<void>(
                              future: _initializeControllerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return CameraPreview(_cameraController);
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _takePhoto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text('Prendre une photo'),
                          ),
                          const SizedBox(height: 16),
                          _imagePath.isNotEmpty
                              ? Image.file(File(_imagePath))
                              : const Text("Aucune image capturée."),
                        ],
                      ),
                    ),
                  customFooter(),
                ],
              ),
            ),
          ),
          customExitButton(context),
        ],
      ),
    ),
  );
}
}

