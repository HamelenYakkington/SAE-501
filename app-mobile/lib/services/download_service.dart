import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sae_501/services/api_service.dart';

class DownloadService {
  final ApiService _apiService = ApiService();

  Future<void> copyAssetToLocal(String assetPath, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${directory.path}/modele');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      final modelFile = File('${modelDir.path}/$fileName');

      // Vérifier si le fichier existe déjà
      if (!await modelFile.exists()) {
        final byteData = await rootBundle.load(assetPath);
        final buffer = byteData.buffer.asUint8List();
        await modelFile.writeAsBytes(buffer);
      }
    } catch (e) {
      print('Erreur lors de la copie de l\'asset: $e');
    }
  }

  Future<File> _downloadFile(String endpoint, String localFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final localFilePath = '${directory.path}/$localFileName';

    final fileData = await _apiService.downloadFile(endpoint);

    final file = File(localFilePath);
    await file.writeAsBytes(fileData);

    return file;
  }

  Future<void> _downloadLabels() async {
    final tags = await _apiService.getTags();

    final labels = tags.map((tag) => tag['label']).toList().join('\n');

    final directory = await getApplicationDocumentsDirectory();
    final modelDir = '${directory.path}/modele';

    await Directory(modelDir).create(recursive: true);

    final labelsFilePath = '$modelDir/labels.txt';

    final file = File(labelsFilePath);
    await file.writeAsString(labels);

    print('Labels téléchargés et enregistrés à : $labelsFilePath');
  }

  Future<void> updateFilesIfNeeded(String remoteVersion) async {
    final directory = await getApplicationDocumentsDirectory();
    final versionFile = File('${directory.path}/version.txt');

    final localVersion = await versionFile.readAsString();

    if (localVersion.trim() != remoteVersion.trim()) {
      await _downloadFile('/api/modele/download', 'modelYolo8.tflite');
      await _downloadLabels();
      await versionFile.writeAsString(remoteVersion);
    }
  }

  Future<void> checkAndUpdateModel() async {
    final directory = await getApplicationDocumentsDirectory();
    final modelDir = '${directory.path}/modele';

    final modelFilePath = '$modelDir/modelYolo8.tflite';
    final labelsFilePath = '$modelDir/labels.txt';
    final versionFilePath = '$modelDir/version.txt';

    final modelFileExists = await File(modelFilePath).exists();
    final labelsFileExists = await File(labelsFilePath).exists();
    final versionFileExists = await File(versionFilePath).exists();

    if (!modelFileExists || !labelsFileExists || !versionFileExists) {
      print('Modèle non trouvé, téléchargement du modèle...');

      // Télécharger les fichiers du modèle
      final modelData = await _apiService.downloadFile('/api/modele/download');
      final versionData = await _apiService.fetchModelVersion();

      await Directory(modelDir).create(recursive: true);
      await File(modelFilePath).writeAsBytes(modelData);
      await File(labelsFilePath).writeAsString('');
      await File(versionFilePath).writeAsString(versionData);

      print('Modèle installé avec succès.');

      await _downloadLabels();
    } else {
      final localVersion = await File(versionFilePath).readAsString();
      final remoteVersion = await _apiService.fetchModelVersion();

      if (localVersion.trim() != remoteVersion.trim()) {
        print('Mise à jour disponible : $remoteVersion (local : $localVersion)');

        final modelData = await _apiService.downloadFile('/api/modele/download');
        await File(modelFilePath).writeAsBytes(modelData);
        await _downloadLabels();

        await File(versionFilePath).writeAsString(remoteVersion);
        print('Mise à jour effectuée avec succès.');
      } else {
        print('Le modèle est déjà à jour : $localVersion');
      }
    }
  }
}
