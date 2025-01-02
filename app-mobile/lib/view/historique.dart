import 'package:flutter/material.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/services/api_service.dart';
import 'package:sae_501/view/displayPhoto.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Historique extends StatefulWidget {
  const Historique({Key? key}) : super(key: key);

  @override
  _Historique createState() => _Historique();
}

class _Historique extends State<Historique> {
  final ApiService _apiService = ApiService();
  List<dynamic> _history = [];
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await checkConnexionToken(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('auth_token');
    });
    fetchUserHistory();
  }

  Future<void> fetchUserHistory() async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun token trouvé.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _apiService.get(
        '/api/user/history',
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      setState(() {
        _history = history;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération de l\'historique personnel: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchAllUsersHistory(int nbr) async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun token trouvé.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _apiService.get(
        '/api/images/latest-history/$nbr',
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      setState(() {
        _history = List.from(history).map((imageData) {
          return {
            'id': imageData['id'],
            'pathImage': imageData['pathImage'],
            'pathLabel': imageData['pathLabel'],
            'date': imageData['date'],
            'time': imageData['time'],
            'labels': imageData['labels'],
          };
        }).toList();
      });
    } catch (e) {
      // Gestion des erreurs lors de la récupération
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des dernières recherches: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHistoryList(List<dynamic> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Aucun historique disponible',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: item['pathImage'] != null
                ? Image.network(dotenv.env['BASE_URL']! + '/' + item['pathImage']!)
                : const Icon(Icons.image_not_supported),
            title: Text('${item['date']} : ${item['time']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Labels : ${item['labels'].join(', ')}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                displayphoto(item['pathImage'], item['pathLabel']);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body : Column(
        children: [
          const SizedBox(height: 25),
          customHeader(
              'KnightSight', 'assets/images/chess_lense_logo.webp'),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: fetchUserHistory,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Personal History'),
                ),
                ElevatedButton(
                  onPressed: () {
                    fetchAllUsersHistory(20);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('All Users History'),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          ) :
          Expanded(
            child: _history.isNotEmpty
                ? _buildHistoryList(_history)
                : const Center(
              child: Text(
                'Aucun historique à afficher.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            "box": [xMin, yMin, xMax, yMax, confidence], // Les coordonnées de la boîte englobante
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

  Future<String?> downloadImage(String imageUrl) async {
    try {
      imageUrl = dotenv.env['BASE_URL']! + imageUrl;
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/downloaded_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else {
        print('Erreur lors du téléchargement de l\'image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors du téléchargement de l\'image: $e');
      return null;
    }
  }

  Future<void> displayphoto(String imagePath, String labelsPath) async {
    List<Map<String, dynamic>> yoloResults = await processYoloFile(labelsPath);
    String? pathTempImage = await downloadImage(imagePath);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
            imagePath: pathTempImage!,
            yoloResults : yoloResults
        ),
      ),
    );


  }
}
