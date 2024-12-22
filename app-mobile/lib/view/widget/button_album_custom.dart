import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart'; // Assuming ViewConstant is imported here

class CustomFolderButton extends StatelessWidget {
  final String folderName;
  final VoidCallback onTap;
  final bool isPrimary;

  const CustomFolderButton({
    Key? key,
    required this.folderName,
    required this.onTap,
    this.isPrimary = false, // Default to secondary style
  }) : super(key: key);

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    String folderNameCapitalized = _capitalizeFirstLetter(folderName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 7),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isPrimary
              ? ViewConstant.backgroundButtonPrimary
              : ViewConstant.backgroundButton,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: isPrimary
              ? ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00A6F4), Color(0xFF434BDE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              folderNameCapitalized,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
              : Text(
            folderNameCapitalized,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
