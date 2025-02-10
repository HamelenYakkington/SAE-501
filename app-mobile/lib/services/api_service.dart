import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String? baseUrl = dotenv.env['BASE_URL'];
  final String? AppLogin = dotenv.env['APP_SECRET_TOKEN'];

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteImage(int id, String? token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/image/delete/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 'Image deleted successfully.') {
          return true;
        } else {
          throw Exception('Erreur: ${responseData['error']}');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTagById(String id) async {
    try {
      final responseData = await get('/api/tag/$id');
      return Map<String, dynamic>.from(responseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isAdmin(String? token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/isadmin'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      if(response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['isadmin'] != null && responseData['isadmin']) {
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }

    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTags() async {
    try {
      final responseData = await get('/api/tags');
      return List<Map<String, dynamic>>.from(responseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> registerUser(String email, String password, String firstName, String lastName) async {
    try {
      final response = await postWithAppToken('/app-request/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });

      if (response['message'] == 'User registered successfully') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendImage(
      BuildContext context,
      File imageFile,
      String label,
      String jwtToken,
      ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await post(
        '/api/upload-image',
        {
          'image': 'data:image/png;base64,$base64Image',
          'label': label,
        },
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response['message'] == 'Image and label uploaded successfully.') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image envoyée avec succès!')),
          );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response['error']}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue: $e')),
      );
      return false;
    }
  }

  Future<String> fetchModelVersion() async {
    try {
      final responseData = await get('/api/modele/version');
      return responseData['version'];
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la version du modèle: $e');
    }
  }

  Future<List<int>> downloadFile(String endpoint) async {
    try {
      final url = endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes.toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du fichier: $e');
    }
  }

  String returnUrl(String endpoint) {
    return endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';
  }

  Future<dynamic> postWithAppToken(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AppLogin',
      };

      final response = await post(endpoint, body, headers: headers);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
