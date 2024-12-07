import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Folder {
  final String name;
  final List<SubFolder> subFolders;

  Folder({required this.name, required this.subFolders});

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      name: json['name'],
      subFolders: (json['sub_albums'] as List)
          .map((subFolder) => SubFolder.fromJson(subFolder))
          .toList(),
    );
  }
}

class SubFolder {
  final String name;
  final List<String> paths;

  SubFolder({required this.name, required this.paths});

  factory SubFolder.fromJson(Map<String, dynamic> json) {
    return SubFolder(
      name: json['name'],
      paths: List<String>.from(json['paths']),
    );
  }
}

// Function to load all folders (previously albums)
Future<List<Folder>> loadFolders() async {
  try {
    final String response = await rootBundle.loadString('assets/album.json');
    final data = json.decode(response);

    return (data['folders'] as List)
        .map((folder) => Folder.fromJson(folder))
        .toList();
  } catch (e) {
    debugPrint('Error in loadFolders: $e');
    return [];
  }
}

// Function to get sub-folders (previously sub-albums) of a specific folder
Future<List<SubFolder>> getSubFolders(String folderName) async {
  try {
    final folders = await loadFolders();
    final folder = folders.firstWhere((folder) => folder.name == folderName, orElse: () => throw Exception('Folder not found'));
    return folder.subFolders;
  } catch (e) {
    debugPrint('Error in getSubFolders: $e');
    return [];
  }
}

// Function to get the first image path of a specific subalbum
Future<String?> getFirstImagePath(String folderName, String subAlbumName) async {
  try {
    final subFolders = await getSubFolders(folderName);
    final subFolder = subFolders.firstWhere(
          (subFolder) => subFolder.name == subAlbumName,
      orElse: () => throw Exception('Subalbum not found'),
    );

    // Return the first image path, or null if the list is empty
    return subFolder.paths.isNotEmpty ? subFolder.paths[0] : null;
  } catch (e) {
    debugPrint('Error in getFirstImagePath: $e');
    return null;
  }
}

// Function to get all image paths from a specific subalbum
Future<List<String>> getAllImagesInSubAlbum(String folderName, String subAlbumName) async {
  try {
    final subFolders = await getSubFolders(folderName);
    final subFolder = subFolders.firstWhere(
          (subFolder) => subFolder.name == subAlbumName,
      orElse: () => throw Exception('Subalbum not found'),
    );

    // Return all image paths
    return subFolder.paths;
  } catch (e) {
    debugPrint('Error in getAllImagesInSubAlbum: $e');
    return [];
  }
}
