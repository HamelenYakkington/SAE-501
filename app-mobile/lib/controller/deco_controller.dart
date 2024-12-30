import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> deco(BuildContext buildContext) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  Navigator.pushReplacementNamed(buildContext, '/login');
}