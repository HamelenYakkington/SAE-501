import 'package:flutter/material.dart';

class SubAlbumButton extends StatelessWidget {
  final String imagePath;
  final String subAlbumName;
  final VoidCallback onTap;

  const SubAlbumButton({
    Key? key,
    required this.imagePath,
    required this.subAlbumName,
    required this.onTap,
  }) : super(key: key);

  // Function to capitalize the first letter of a string
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 4.0,
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "> ${_capitalizeFirstLetter(subAlbumName)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
