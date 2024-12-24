import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/button_exit_custom.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/displayPhoto.dart';
import 'package:sae_501/view/widget/button_pick_image_custom.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<Camera> {
  late CameraController controller;
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;

  CameraImage? cameraImage;
  File? _selectedImage;
  bool isLoaded = false;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
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
    controller.dispose();
    await vision.closeYoloModel();
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/modelYolo8.tflite',
        modelVersion: "yolov8",
        numThreads: 1,
        useGpu: true);
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }

  Future<void> yoloOnPicture(File image) async {
    try {
      // Lire et décoder l'image
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
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.7,
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
        setState(() {
          _selectedImage = imageFile;
        });
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