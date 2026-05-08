import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<PlaylistModel> _playlists = [];
  List<String> _recentlyPlayed = [];

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => _playlists;
  List<String> get recentlyPlayed => _recentlyPlayed;

  String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> _loadPlaylists() async {
    _playlists = await _storageService.getPlaylists();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: _generateId(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists.add(playlist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(name: newName);
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedSongIds = List<String>.from(_playlists[index].songIds)
        ..add(songId);
      _playlists[index] = _playlists[index].copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedSongIds = List<String>.from(_playlists[index].songIds)
        ..remove(songId);
      _playlists[index] = _playlists[index].copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  List<SongModel> getPlaylistSongs(String playlistId, List<SongModel> allSongs) {
    final playlist = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => PlaylistModel(
        id: '',
        name: '',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return allSongs.where((s) => playlist.songIds.contains(s.id)).toList();
  }

  void addToRecentlyPlayed(String songId) {
    _recentlyPlayed.remove(songId);
    _recentlyPlayed.insert(0, songId);
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 50);
    }
    notifyListeners();
  }
}
