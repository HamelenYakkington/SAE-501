import 'package:flutter/material.dart';
import 'package:sae_501/constants/validator.dart';
import 'package:sae_501/services/api_service.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/input_text_custom.dart';

class Register extends StatefulWidget {
  @override
  _Register createState() => _Register();
}

class _Register extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool isRegistered = await ApiService().registerUser(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          _lastNameController.text,
        );

        if (isRegistered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inscription réussie !')),
          );
          Navigator.pushNamed(context, '/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'inscription')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: Container(
        color: ViewConstant.backgroundApp,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 25),
                  customHeader(
                      'KnightSight', 'assets/images/chess_lense_logo.webp'),
                  const SizedBox(height: 25),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextInput(
                          labelText: 'Nom',
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          validator: Validator.lastNameValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomTextInput(
                          labelText: 'Prenom',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          validator: Validator.nameValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomTextInput(
                          labelText: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validator.emailValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomTextInput(
                          obscure: true,
                          labelText: 'Mot de passe',
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          validator: Validator.passwordValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomTextInput(
                          obscure: true,
                          labelText: 'Confirmation Mot de passe',
                          controller: _passwordConfirmationController,
                          keyboardType: TextInputType.text,
                          validator: (value) => Validator.confirmPasswordValidator(
                              value, _passwordController),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text("Connexion"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  customFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
