import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/song_model.dart';

class SampleSongService {
  static const List<Map<String, String>> _sampleSongs = [
    {'title': 'Morning Melody', 'artist': 'Sample Artist', 'file': 'song1.wav'},
    {'title': 'Sunny Day', 'artist': 'Sample Artist', 'file': 'song2.wav'},
    {'title': 'Evening Breeze', 'artist': 'Sample Artist', 'file': 'song3.wav'},
  ];

  Future<List<SongModel>> loadSampleSongs() async {
    final dir = await getApplicationDocumentsDirectory();
    final sampleDir = Directory('${dir.path}/sample_songs');
    if (!await sampleDir.exists()) {
      await sampleDir.create(recursive: true);
      for (final song in _sampleSongs) {
        try {
          final data = await rootBundle.load('assets/audio/sample_songs/${song['file']}');
          final file = File('${sampleDir.path}/${song['file']}');
          await file.writeAsBytes(data.buffer.asUint8List());
        } catch (e) {
          debugPrint('Error extracting sample song: $e');
        }
      }
    }

    final songs = <SongModel>[];
    for (int i = 0; i < _sampleSongs.length; i++) {
      final info = _sampleSongs[i];
      final file = File('${sampleDir.path}/${info['file']}');
      if (await file.exists()) {
        songs.add(SongModel(
          id: 'sample_$i',
          title: info['title']!,
          artist: info['artist']!,
          filePath: file.path,
          duration: Duration(seconds: 3),
        ));
      }
    }
    return songs;
  }
}
