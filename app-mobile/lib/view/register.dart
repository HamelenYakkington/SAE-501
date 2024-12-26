import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sae_501/constants/validator.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordConfirmationController.dispose();
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
                            labelText: 'Nom',
                            controller: _lastNameController,
                            keyboardType: TextInputType.name,
                            validator: Validator.lastNameValidator),
                        const SizedBox(height: 16),
                        CustomTextInput(
                            labelText: 'Prenom',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            validator: Validator.nameValidator),
                        const SizedBox(height: 16),
                        CustomTextInput(
                            labelText: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validator.emailValidator),
                        const SizedBox(height: 16),
                        CustomTextInput(
                            obscure: true,
                            labelText: 'Mot de passe',
                            controller: _passwordController,
                            keyboardType: TextInputType.name,
                            validator: Validator.passwordValidator),
                        const SizedBox(height: 16),
                        CustomTextInput(
                            obscure: true,
                            labelText: 'Confirmation Mot de passe',
                            controller: _passwordConfirmationController,
                            keyboardType: TextInputType.name,
                            validator: (value) => Validator.confirmPasswordValidator(value, _passwordController)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text("Connexion"),
                        ),
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
