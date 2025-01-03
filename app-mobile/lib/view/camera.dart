import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/services/download_service.dart';
import 'package:sae_501/view/widget/button_exit_custom.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/displayPhoto.dart';
import 'package:sae_501/view/widget/button_pick_image_custom.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<Camera> {
  late CameraController controller;
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;
  bool _isModelClosed = true;
  DownloadService _downloadService = DownloadService();

  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    checkConnexionToken(context);
    init();
  }

  init() async {
    List<CameraDescription> cameras = await availableCameras();
    vision = FlutterVision();
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
      print("Yolo modele closed");
    }
  }

  Future<void> loadYoloModel() async {
    final directory = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${directory.path}/modele');

    final modelFilePath = '${modelDir.path}/modelYolo8.tflite';
    final labelsFilePath ='${modelDir.path}/labels.txt';
    final versionFilePath ='${modelDir.path}/version.txt';

    final modelFileExists = await File(modelFilePath).exists();
    final labelsFileExists = await File(labelsFilePath).exists();
    final versionFileExists = await File(versionFilePath).exists();

    Directory('${directory.path}/modele');

    if (!modelFileExists) {
        await _downloadService.copyAssetToLocal('assets/modelYolo8.tflite', 'modelYolo8.tflite');
    }
    if (!labelsFileExists) {
      await _downloadService.copyAssetToLocal('assets/labels.txt', 'labels.txt');
    }
    if (!versionFileExists) {
      await _downloadService.copyAssetToLocal('assets/version.txt', 'version.txt');
    }
    final modelFile = File(modelFilePath);
    final labelsFile = File(labelsFilePath);
    final versionFile = File(versionFilePath);


    print('Model path: ${modelFile.path}');
    print('Labels path: ${labelsFile.path}');
    print('Version path: ${versionFile.path}');

    print('Version exists: ${versionFile.existsSync()}');
    print('Model exists: ${modelFile.existsSync()}');
    print('Labels exists: ${labelsFile.existsSync()}');

    await vision.loadYoloModel(
      labels: labelsFilePath,
      modelPath: modelFilePath,
      modelVersion: "yolov8",
      numThreads: 1,
      useGpu: true,
      is_asset:false,
    );

    print("Chargé !");

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
        confThreshold: 0.4,
        classThreshold: 0.3);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
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

      final result = await vision.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: imageHeight,
        imageWidth: imageWidth,
        iouThreshold: 0.2,
        confThreshold: 0.2,
        classThreshold: 0.2,
      );
      if (result.isNotEmpty) {
        setState(() {
          yoloResults = result;
        });
      }
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
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      double objectX = result["box"][0] * factorX;
      double objectY = result["box"][1] * factorY;
      double objectWidth = (result["box"][2] - result["box"][0]) * factorX;
      double objectHeight = (result["box"][3] - result["box"][1]) * factorY;

      return Positioned(
        left: objectX,
        top: objectY,
        width: objectWidth,
        height: objectHeight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(2)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: const Color.fromARGB(255, 115, 0, 255),
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Méthode pour charger une image depuis le système
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        await yoloOnPicture(imageFile);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(
                imagePath: imageFile.path,
                yoloResults : yoloResults
            ),
          ),
        );
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image : $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      if(!isLoaded)
        return;
      final XFile photo = await controller.takePicture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
              imagePath: photo.path,
              yoloResults : yoloResults
          ),
        ),
      );
    } catch (e) {
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