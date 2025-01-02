import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sae_501/services/api_service.dart';
import 'package:sae_501/view/displayPhoto.dart';
import 'package:path_provider/path_provider.dart';

class HistoryService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> processYoloFile(String fileUrl) async {
    List<Map<String, dynamic>> yoloResults = [];
    String fileContent = await _readFile(fileUrl);
    List<String> lines = fileContent.split('\n');

    for (var line in lines) {
      List<String> parts = line.trim().split(' ');
      if (parts.length == 6) {
        try {
          String tag = parts[0];
          double confidence = double.parse(parts[1]);
          double xMin = double.parse(parts[2]);
          double yMin = double.parse(parts[3]);
          double xMax = double.parse(parts[4]);
          double yMax = double.parse(parts[5]);

          Map<String, dynamic> labelTag = await _apiService.getTagById(tag);
          Map<String, dynamic> result = {
            "tag": labelTag['label'],
            "box": [
              xMin,
              yMin,
              xMax,
              yMax,
              confidence
            ], // Les coordonnées de la boîte englobante
          };

          yoloResults.add(result);
        } catch (e) {
          print("Erreur en traitant la ligne: $line");
        }
      } else {
        print("Ligne ignorée, nombre d'éléments incorrect: $line");
      }
    }

    return yoloResults;
  }

  Future<String> _readFile(String fileUrl) async {
    String fileContent = '';
    try {
      fileUrl = dotenv.env['BASE_URL']! + fileUrl;
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        fileContent = response.body;
      } else {
        throw Exception('Échec du téléchargement du fichier');
      }
    } catch (e) {
      print("Erreur lors de la lecture du fichier: $e");
    }
    return fileContent;
  }

  String getFileNameWithExtensionFromLocal(String filePath) {
    final file = File(filePath);
    final fileNameWithExtension = file.uri.pathSegments.last;
    return fileNameWithExtension;
  }

  Future<String?> downloadImage(String imageUrl) async {
    try {
      imageUrl = dotenv.env['BASE_URL']! + imageUrl;
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        String nameFile = getFileNameWithExtensionFromLocal(imageUrl);
        final filePath = '${directory.path}/{$nameFile}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else {
        print(
            'Erreur lors du téléchargement de l\'image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors du téléchargement de l\'image: $e');
      return null;
    }
  }

  Future<List?> fetchUserHistory(String? token, BuildContext context) async {
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun token trouvé.')),
      );
      return null;
    }

    try {
      return await _apiService.get(
        '/api/user/history',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de la récupération de l\'historique personnel: $e')),
      );
    }
  }

  Future<List?> fetchAllUsersHistory(int nbr, String? token, BuildContext context) async {
    print("sdfffffffffffffffffffffffffffffffffffffffffff");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun token trouvé.')),
      );
      return null;
    }

    try {
      final history = await _apiService.get(
        '/api/images/latest-history/$nbr',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return List.from(history).map((imageData) {
          return {
            'id': imageData['id'],
            'pathImage': imageData['pathImage'],
            'pathLabel': imageData['pathLabel'],
            'date': imageData['date'],
            'time': imageData['time'],
            'labels': imageData['labels'],
          };
        }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de la récupération des dernières recherches: $e')),
      );
      return null;
    }
  }

  Future<void> displayphoto(String imagePath, String labelsPath, BuildContext context) async {
    List<Map<String, dynamic>> yoloResults = await processYoloFile(labelsPath);
    String? pathTempImage = await downloadImage(imagePath);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
            imagePath: pathTempImage!, yoloResults: yoloResults),
      ),
    );
  }



}
