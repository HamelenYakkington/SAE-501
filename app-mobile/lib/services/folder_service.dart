import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

Future<List<String>> loadAlbumFolders() async {
  try {
    final String response = await rootBundle.loadString('assets/album.json');
    final data = json.decode(response);
    return List<String>.from(data['folders']);
  } catch (e) {
    debugPrint('Error in loadAlbumFolders: $e');
    return []; // Return an empty list in case of an error
  }
}



