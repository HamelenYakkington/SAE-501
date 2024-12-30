import 'package:flutter/material.dart';
import 'package:sae_501/constants/validator.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/input_text_custom.dart';
import 'package:sae_501/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sae_501/controller/verif_connexion.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    connexionByToken(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await _apiService.post('/login_token', {
          'email': _emailController.text,
          'password': _passwordController.text,
        });

        if (response['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', response['token']);
          Navigator.pushNamed(context, '/');
        } else {
          throw Exception('Token manquant dans la réponse');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: Container(
        color: ViewConstant.backgroundApp,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 25),
              customHeader(
                  'KnightSight', 'assets/images/chess_lense_logo.webp'),
              const SizedBox(height: 25),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextInput(
                          labelText: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validator.emailValidator
                        ),
                        const SizedBox(height: 16),
                        CustomTextInput(
                            obscure: true,
                            labelText: 'Mot de passe',
                            controller: _passwordController,
                            keyboardType: TextInputType.name,
                            validator: Validator.passwordValidator
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children : [
                            ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text("Connexion"),
                          ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text("Inscription"),
                            ),
                        ]
                        )
                      ],
                    ),
                  ),
                ),
              ),
              customFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
