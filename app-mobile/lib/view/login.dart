import 'package:flutter/material.dart';
import 'package:sae_501/constants/validator.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/input_text_custom.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, '/');
    }
  }

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
