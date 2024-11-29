import 'package:flutter/material.dart';


Widget gridBuilderCustom(Function function, items, context) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
    ),
    itemCount: items.length,
    itemBuilder: (localContext, index) {
      final item = items[index];
      return function(
        item,
        localContext,
      );
    },
  );
}