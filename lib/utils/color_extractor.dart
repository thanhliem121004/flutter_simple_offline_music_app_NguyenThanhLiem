import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color> extractDominantColor(String imagePath) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        FileImage(File(imagePath)),
        size: const Size(100, 100),
      );
      return paletteGenerator.dominantColor?.color ?? const Color(0xFF282828);
    } catch (e) {
      return const Color(0xFF282828);
    }
  }
}
