import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  _cameras = await availableCameras();
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  List<dynamic> _recognitions = [];
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    initializeTFLite();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startImageStream((CameraImage img) {
        if (isDetecting) return;
        isDetecting = true;
        runModelOnFrame(img).then((recognitions) {
          setState(() {
            _recognitions = recognitions ?? []; // Handle null
            isDetecting = false;
          });
        });
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> initializeTFLite() async {
    String? res = await Tflite.loadModel(
      model: "assets/yolo_v5.tflite",
      labels: "assets/labels.txt",
    );
    print(res);
  }

  Future<List<dynamic>?> runModelOnFrame(CameraImage image) async {
    var recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      model: "YOLO",
      imageHeight: image.height,
      imageWidth: image.width,
      rotation: 90,
      threshold: 0.5,
      asynch: true,
    );
    return recognitions;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Object Detection')),
      body: Stack(
        children: [
          CameraPreview(controller),
          if (_recognitions.isNotEmpty)
            CustomPaint(
              painter: RecognitionPainter(_recognitions),
              child: Container(),
            ),
        ],
      ),
    );
  }
}

class RecognitionPainter extends CustomPainter {
  final List<dynamic> recognitions;

  RecognitionPainter(this.recognitions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    final textStyle = TextStyle(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (var recognition in recognitions) {
      final rect = recognition['rect'];
      final left = rect['x'] * size.width;
      final top = rect['y'] * size.height;
      final right = left + (rect['w'] * size.width);
      final bottom = top + (rect['h'] * size.height);

      // Draw bounding box
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

      // Draw label
      final textSpan = TextSpan(
        text: recognition['label'],
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(left, top));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever recognitions change
  }
}