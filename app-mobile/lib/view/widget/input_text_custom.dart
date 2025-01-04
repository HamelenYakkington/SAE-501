import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';

class CustomTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final bool obscure;

  const CustomTextInput({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
  }) : super(key: key);

  @override
  CustomTextInputState createState() => CustomTextInputState();
}

class CustomTextInputState extends State<CustomTextInput> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        floatingLabelStyle: TextStyle(
          color: hasError ? ViewConstant.ColorLabelInputError : Colors.white,
        ),
        labelStyle: const TextStyle(
          color: ViewConstant.ColorLabelInput,
          letterSpacing: 1.3,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: ViewConstant.ColorBorderInput,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: ViewConstant.ColorBorderInputError,
          ),
        ),
        errorStyle: const TextStyle(
          color: ViewConstant.ColorLabelInputError,
          letterSpacing: 1.3,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: ViewConstant.ColorBorderInput, width: 2.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: ViewConstant.ColorBorderInputError, width: 2.0),
        ),
      ),
      style: const TextStyle(
        color: ViewConstant.ColorInput,
      ),
      obscureText: widget.obscure,
      obscuringCharacter: '*',
      keyboardType: widget.keyboardType,
      validator: (value) {
        final error = widget.validator(value);
        setState(() {
          hasError = error != null;
        });
        return error;
      },
    );
  }
}
