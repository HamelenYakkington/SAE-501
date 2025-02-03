import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/services/download_service.dart';
import 'package:sae_501/view/widget/button_exit_custom.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/display_photo.dart';
import 'package:sae_501/view/widget/button_pick_image_custom.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sae_501/view/widget/returnBoxes.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<Camera> {
  late CameraController controller;
  late FlutterVision vision;
  late FlutterVision analyse;
  late List<Map<String, dynamic>> yoloResults;
  bool _isModelClosed = true;
  final DownloadService _downloadService = DownloadService();

  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;

  int _frameSkipCounter = 0;
  final int _framesToSkip = 30;

  @override
  void initState() {
    super.initState();
    checkConnexionToken(context);
    init();
  }

  init() async {
    List<CameraDescription> cameras = await availableCameras();
    vision = FlutterVision();
    analyse = FlutterVision();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
    await loadYoloModel();
    setState(() {
      isLoaded = true;
      isDetecting = true;
      yoloResults = [];
    });
    await startDetection();
  }

  @override
  void dispose() async {
    super.dispose();
    isDetecting = false;
    if (!_isModelClosed) {
      controller.dispose();
      await vision.closeYoloModel();
      _isModelClosed = true;
    }
  }

  Future<void> loadYoloModel() async {
    final directory = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${directory.path}/modele');
    final modeleHeavyDir = Directory('${modelDir.path}/heavy');
    final modeleLightDir = Directory('${modelDir.path}/light');

    final modeleHeavyVersionPath = '${modeleHeavyDir.path}/version.txt';
    final modeleLightVersionPath = '${modeleLightDir.path}/version.txt';

    final modeleHeavyModelePath = '${modeleHeavyDir.path}/modelYolo8.tflite';
    final modeleLightModelePath = '${modeleLightDir.path}/modelYolo8.tflite';

    final labelsFilePath = '${modelDir.path}/labels.txt';

    final labelsFileExists = await File(labelsFilePath).exists();

    final modeleHeavyVersionExist = await File(modeleHeavyVersionPath).exists();
    final modeleLightVersionExist = await File(modeleLightVersionPath).exists();
    final modeleHeavyModeleExist = await File(modeleHeavyModelePath).exists();
    final modeleLightModeleExist = await File(modeleLightModelePath).exists();

    if (!labelsFileExists) {
      await _downloadService.copyAssetToLocal(
          'assets/modele/labels.txt', 'modele/labels.txt');
    }
    if (!modeleHeavyVersionExist) {
      await _downloadService.copyAssetToLocal(
          'assets/modele/heavy/version.txt', 'modele/heavy/version.txt');
    }
    if (!modeleLightVersionExist) {
      await _downloadService.copyAssetToLocal(
          'assets/modele/light/version.txt', 'modele/light/version.txt');
    }
    if (!modeleHeavyModeleExist) {
      await _downloadService.copyAssetToLocal(
          'assets/modele/heavy/modelYolo8.tflite',
          'modele/heavy/modelYolo8.tflite');
    }
    if (!modeleLightModeleExist) {
      await _downloadService.copyAssetToLocal(
          'assets/modele/light/modelYolo8.tflite',
          'modele/light/modelYolo8.tflite');
    }

    await vision.loadYoloModel(
      labels: labelsFilePath,
      modelPath: modeleLightModelePath,
      modelVersion: "yolov8",
      numThreads: 1,
      useGpu: true,
      is_asset: false,
    );

    await analyse.loadYoloModel(
      labels: labelsFilePath,
      modelPath: modeleHeavyModelePath,
      modelVersion: "yolov8",
      numThreads: 1,
      useGpu: true,
      is_asset: false,
    );

    setState(() {
      isLoaded = true;
      _isModelClosed = false;
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.6,
        classThreshold: 0.6);
    setState(() {
      yoloResults = result;
    });
  }

  Future<void> yoloOnPicture(File image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception("L'image n'a pas pu être décodée.");
      }

      final imageWidth = decodedImage.width;
      final imageHeight = decodedImage.height;

      final result = await analyse.yoloOnImage(
          bytesList: imageBytes,
          imageHeight: imageHeight,
          imageWidth: imageWidth,
          iouThreshold: 0.4,
          confThreshold: 0.6,
          classThreshold: 0.6);
      setState(() {
        yoloResults = result;
      });
    } catch (e) {
      print("Erreur lors de l'exécution de YOLO sur l'image : $e");
    }
  }

  Future<void> startDetection() async {
    if (!controller.value.isInitialized || controller.value.isStreamingImages) {
      return;
    }
    setState(() {
      isDetecting = true;
    });
    await controller.startImageStream((image) async {
      if (isDetecting) {
        _frameSkipCounter++;
        if (_frameSkipCounter % _framesToSkip == 0) {
          cameraImage = image;
          await yoloOnFrame(image);
        }
      }
    });
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    return returnBoxes(screen, yoloResults, factorX, factorY);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        await yoloOnPicture(imageFile);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(
                imagePath: imageFile.path, yoloResults: yoloResults),
          ),
        );
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image : $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      if (!isLoaded) {
        return;
      }
      final XFile photo = await controller.takePicture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
              imagePath: photo.path, yoloResults: yoloResults),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la prise de photo : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (isLoaded) ...[
                                  AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: CameraPreview(controller),
                                  ),
                                  ...displayBoxesAroundRecognizedObjects(size),
                                ] else
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      strokeWidth: 4.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: customButtonPhoto(
                onTap: _takePhoto,
                context: context,
              ),
            ),
            customPickImage(pickImage),
            customExitButton(context),
          ],
        ),
      ),
    );
  }
}
