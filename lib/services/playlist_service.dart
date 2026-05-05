import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;
import '../models/song_model.dart';

class PlaylistService {
  final audio_query.OnAudioQuery _audioQuery = audio_query.OnAudioQuery();

  Future<bool> _ensurePermission() async {
    try {
      final status = await _audioQuery.permissionsStatus();
      if (status) return true;
      final requested = await _audioQuery.permissionsRequest();
      return requested;
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false;
    }
  }

  Future<List<SongModel>> getAllSongs() async {
    try {
      final hasPermission = await _ensurePermission();
      if (!hasPermission) return [];

      final audioList = await _audioQuery.querySongs(
        sortType: audio_query.SongSortType.TITLE,
        orderType: audio_query.OrderType.ASC_OR_SMALLER,
        uriType: audio_query.UriType.EXTERNAL,
        ignoreCase: true,
      );

      return audioList.map<SongModel>((audio) => SongModel.fromAudioQuery(audio)).toList();
    } catch (e) {
      debugPrint('Error loading songs: $e');
      return [];
    }
  }

  Future<List<SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.artist == artist).toList();
  }

  Future<List<SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.album == album).toList();
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
