import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sae_501/services/api_service.dart';

Future<bool> _checkToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  if (token == null) {
    return false;
  }
  if( await verifyToken(token) != true) {
    return false;
  }
  return true;
}

Future<bool> verifyToken(String token) async {
  ApiService apiService = ApiService();

  try {
    final response = await apiService.post(
      '/api/token/validate',
      {},
      headers: {'Authorization': 'Bearer $token'},
    );

    return response['valid'];
  } catch (e) {
    debugPrint('Erreur lors de la validation du token : $e');
    return false;
  }
}

Future<void> connexionByToken(BuildContext context) async {
  bool valid = await _checkToken();
  if(valid) {
    Navigator.pushReplacementNamed(context, '/');
  }
}

Future<void> checkConnexionToken(BuildContext context) async {
  bool valid = await _checkToken();
  if(!valid) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}