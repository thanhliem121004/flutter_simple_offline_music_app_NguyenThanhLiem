import 'dart:io';
import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {
  final SongModel song;
  final double size;

  const AlbumArt({
    super.key,
    required this.song,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.albumArtBorderRadius),
        color: AppConstants.cardColor,
      ),
      child: song.albumArt != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.albumArtBorderRadius),
              child: Image.file(
                File(song.albumArt!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Icon(Icons.music_note, color: Colors.grey);
  }
}
