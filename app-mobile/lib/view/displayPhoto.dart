import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/services/api_service.dart';
import 'package:sae_501/view/widget/button_exit_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final List<Map<String, dynamic>> yoloResults;

  const DisplayPictureScreen({
    required this.imagePath,
    required this.yoloResults,
  });

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  ApiService apiService = ApiService();
  bool disabledBtn = false;

  @override
  void initState() {
    super.initState();
    checkConnexionToken(context);
    if(widget.yoloResults.isEmpty) {
      disabledBtn = true;
    }
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (widget.yoloResults.isEmpty) return [];
    final imageFile = File(widget.imagePath);
    final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    double imageWidth = image.width.toDouble();
    double imageHeight = image.height.toDouble();

    double factorX = screen.width / imageWidth;
    double factorY = screen.height / imageHeight;


    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return widget.yoloResults.map((result) {
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

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Results Details",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...widget.yoloResults.map((result) {
                return ListTile(
                  title: Text(result['tag']),
                  subtitle: Text(
                    "Confidence: ${(result['box'][4] * 100).toStringAsFixed(2)}%",
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              ElevatedButton(

                onPressed: () async {
                  Navigator.pop(context);
                  await _sendResults();
                },
                child: const Text("Send Results"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendResults() async {
    try {
      setState(() {
        disabledBtn = true;
      });

      final label = widget.yoloResults.map((result) {
        final tag = result['tag'];
        final box = result['box'];
        return '${tag} ${box[4]} ${box[0]} ${box[1]} ${box[2]} ${box[3]}';
      }).join('\n');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('auth_token')!;

      final success = await apiService.sendImage(
        context,
        File(widget.imagePath),
        label,
        token,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Results sent successfully!')),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send results.')),
        );
        setState(() {
          disabledBtn = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      setState(() {
        disabledBtn = false;
      });
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
                            child: Stack(fit: StackFit.expand, children: [
                              Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.fitHeight,
                              ),
                              ...displayBoxesAroundRecognizedObjects(size),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if(disabledBtn == false)
              Positioned(
                bottom: 5,
                right: 5,
                child: ElevatedButton(
                  onPressed: () => _showModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Send Results"),
                ),
              ),
            customExitButton(context),
          ],
        ),
      ),
    );
  }
}
