import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ObjectDetection {
  static const String _modelPath = 'assets/modelYolo8.tflite';
  static const String _labelPath = 'assets/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = [];

  // Constructor: Load the model and labels
  ObjectDetection() {
    _loadModel();
    _loadLabels();
  }

  // Load TensorFlow Lite model
  Future<void> _loadModel() async {
    final interpreterOptions = InterpreterOptions();

    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    if (Platform.isIOS) {
      interpreterOptions.addDelegate(GpuDelegate());
    }

    _interpreter = await Interpreter.fromAsset(_modelPath, options: interpreterOptions);
  }

  // Load labels from file
  Future<void> _loadLabels() async {
    final labelsRaw = await rootBundle.loadString(_labelPath);
    _labels = labelsRaw.split('\n');
  }

  // Analyze the image and run inference
  Future<Uint8List> analyseImage(String imagePath) async {
    print("Analyse en cours");
    // Load the image
    final imageData = File(imagePath).readAsBytesSync();
    final image = img.decodeImage(imageData);

    // Resize the image to match the input size expected by the model
    final imageInput = img.copyResize(image!, width: 640, height: 640);

    // Convert the image into a matrix of RGB values
    final imageMatrix = List.generate(
      imageInput.height,
          (y) => List.generate(
        imageInput.width,
            (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        },
      ),
    );

    // Run inference
    final output = await _runInference(imageMatrix);

    // Process the output (bounding boxes, classes, and scores)
    final scoresTensor = output[0].first as List<double>;
    final boxesTensor = output[1].first as List<List<double>>;
    final classesTensor = output[3].first as List<double>;

    final List<List<int>> locations = boxesTensor
        .map((box) => box.map((value) => ((value * 300).toInt())).toList())
        .toList();

    final classes = classesTensor.map((value) => value.toInt()).toList();

    final numberOfDetections = output[2].first as double;

    final List<String> classification = [];
    for (int i = 0; i < numberOfDetections; i++) {
      classification.add(_labels[classes[i]]);
      print(_labels[classes[i]]);
    }

    // Draw bounding boxes and labels on the image
    for (var i = 0; i < numberOfDetections; i++) {
      if (scoresTensor[i] > 0.85) {
        img.drawRect(
          imageInput,
          x1: locations[i][1],
          y1: locations[i][0],
          x2: locations[i][3],
          y2: locations[i][2],
          color: img.ColorRgb8(0, 255, 0),
          thickness: 3,
        );

        img.drawString(
          imageInput,
          '${classification[i]} ${scoresTensor[i]}',
          font: img.arial14,
          x: locations[i][1] + 7,
          y: locations[i][0] + 7,
          color: img.ColorRgb8(0, 255, 0),
        );
      }
    }

    // Return the modified image as a byte array
    return img.encodeJpg(imageInput);
  }

  // Run inference with the given input
  Future<List<List<Object>>> _runInference(List<List<List<num>>> imageMatrix) async {
    final input = [imageMatrix];

    final output = {
      0: [List<num>.filled(10, 0.0)],
      1: [List<List<num>>.filled(10, List<num>.filled(4, 0.0))],
      2: [0.0],
      3: [List<num>.filled(10, 0.0)],
    };

    // Perform the inference
    _interpreter!.runForMultipleInputs([input], output);
    print("Fin Analyse");
    // Return the results
    return output.values.toList();
  }
}
