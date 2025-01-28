// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sae_501/services/api_service.dart';
import 'package:path/path.dart' as path;


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

  Future<void> checkAndUpdateModel(Function(double) onProgress) async {
    final directory = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${directory.path}/modele');
    final heavyDir = Directory('${modelDir.path}/heavy');
    final lightDir = Directory('${modelDir.path}/light');

    final heavyModelFilePath = '${heavyDir.path}/modelYolo8.tflite';
    final lightModelFilePath = '${lightDir.path}/modelYolo8.tflite';
    final labelsFilePath = '${modelDir.path}/labels.txt';
    final heavyVersionFilePath = '${heavyDir.path}/version.txt';
    final lightVersionFilePath = '${lightDir.path}/version.txt';

    await heavyDir.create(recursive: true);
    await lightDir.create(recursive: true);

    try {
      final metadata = await _apiService.get('/api/modele/metadata');
      final heavy = metadata['heavy'];
      final light = metadata['light'];

      final heavyVersionLocal = await _readFileContent(heavyVersionFilePath);
      if (heavyVersionLocal.trim() != heavy['version'].trim()) {
        print('Mise à jour du modèle "heavy"...');
        await _downloadAndSaveFileWithProgress(
            heavy['model'],
            heavyModelFilePath,
                (progress) {
              onProgress(progress);
            }
        );
        await _writeFileContent(heavyVersionFilePath, heavy['version']);
      } else {
        print('Le modèle "heavy" est déjà à jour.');
      }

      final lightVersionLocal = await _readFileContent(lightVersionFilePath);
      if (lightVersionLocal.trim() != light['version'].trim()) {
        print('Mise à jour du modèle "light"...');
        await _downloadAndSaveFileWithProgress(
            light['model'],
            lightModelFilePath,
                (progress) {
              onProgress(progress);
            }
        );
        await _writeFileContent(lightVersionFilePath, light['version']);
      } else {
        print('Le modèle "light" est déjà à jour.');
      }

      final labelsFileExists = await File(labelsFilePath).exists();
      if (!labelsFileExists) {
        await _downloadLabels();
      }
    } catch (e) {
      print('Erreur lors de la vérification/mise à jour des modèles : $e');
    }
  }



  Future<String> _readFileContent(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }

  Future<void> _writeFileContent(String filePath, String content) async {
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<void> _downloadAndSaveFileWithProgress(
      String endpoint,
      String localPath,
      Function(double) onProgress) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final localFile = File(localPath.startsWith('/')
          ? localPath
          : path.join(directory.path, localPath));

      final client = HttpClient();
      final url = _apiService.returnUrl(endpoint);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      final contentLength = response.headers.value(HttpHeaders.contentLengthHeader);
      final totalSize = contentLength != null ? int.parse(contentLength) : -1;
      int downloadedSize = 0;

      final file = await localFile.create(recursive: true);
      final sink = file.openWrite();

      await for (var data in response) {
        downloadedSize += data.length;
        sink.add(data);

        if (totalSize > 0) {
          double progress = downloadedSize / totalSize;
          onProgress(progress);
        }
      }

      await sink.flush();
      await sink.close();

      print('Fichier téléchargé et sauvegardé à : ${localFile.path}');
    } catch (e) {
      print('Erreur lors du téléchargement : $e');
    }
  }

}
