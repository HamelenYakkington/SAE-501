import 'package:flutter/material.dart';
import 'package:sae_501/view/widget/button_nav_acceuil_custom.dart';

Widget gridBuilderCustom(function, items, context) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
    ),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return customButtonNavAcceuil(
        item,
        context,
      );
    },
  );
}