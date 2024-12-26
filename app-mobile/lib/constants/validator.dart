import 'package:flutter/cupertino.dart';

class Validator {
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Veuillez entrer un mot de passe.";
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Veuillez entrer un email.";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Veuillez entrer un email valide.";
    }
    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Veuillez entrer un prenom.";
    }
    return null;
  }

  static String? lastNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Veuillez entrer un nom.";
    }
    return null;
  }

  static String? confirmPasswordValidator(String? value, TextEditingController passwordController) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}
