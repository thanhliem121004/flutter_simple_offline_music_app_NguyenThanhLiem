import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/models/playback_state_model.dart';
import 'package:offline_music_player/models/album_model.dart';
import 'package:offline_music_player/utils/duration_formatter.dart';

void main() {
  group('SongModel', () {
    test('fromJson and toJson round trip', () {
      final song = SongModel(
        id: '1',
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        filePath: '/path/to/song.mp3',
        duration: const Duration(milliseconds: 200000),
        albumArt: '/path/to/art.jpg',
        fileSize: 5000000,
      );

      final json = song.toJson();
      final restored = SongModel.fromJson(json);

      expect(restored.id, song.id);
      expect(restored.title, song.title);
      expect(restored.artist, song.artist);
      expect(restored.album, song.album);
      expect(restored.filePath, song.filePath);
      expect(restored.duration, song.duration);
      expect(restored.albumArt, song.albumArt);
      expect(restored.fileSize, song.fileSize);
    });

    test('fromJson handles null duration', () {
      final json = {
        'id': '1',
        'title': 'Test',
        'artist': 'Artist',
        'filePath': '/path/to/song.mp3',
      };

      final song = SongModel.fromJson(json);
      expect(song.duration, isNull);
    });
  });

  group('PlaylistModel', () {
    test('fromJson and toJson round trip', () {
      final playlist = PlaylistModel(
        id: '1',
        name: 'My Playlist',
        songIds: ['1', '2', '3'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        coverImage: '/path/to/cover.jpg',
      );

      final json = playlist.toJson();
      final restored = PlaylistModel.fromJson(json);

      expect(restored.id, playlist.id);
      expect(restored.name, playlist.name);
      expect(restored.songIds, playlist.songIds);
      expect(restored.coverImage, playlist.coverImage);
    });

    test('copyWith updates fields correctly', () {
      final playlist = PlaylistModel(
        id: '1',
        name: 'Old Name',
        songIds: ['1'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = playlist.copyWith(name: 'New Name', songIds: ['1', '2']);
      expect(updated.name, 'New Name');
      expect(updated.songIds, ['1', '2']);
      expect(updated.id, '1');
    });
  });

  group('PlaybackState', () {
    test('progress returns 0 when duration is 0', () {
      final state = PlaybackState(
        position: const Duration(seconds: 30),
        duration: Duration.zero,
        isPlaying: true,
      );
      expect(state.progress, 0.0);
    });

    test('progress returns correct ratio', () {
      final state = PlaybackState(
        position: const Duration(seconds: 30),
        duration: const Duration(seconds: 60),
        isPlaying: true,
      );
      expect(state.progress, 0.5);
    });
  });

  group('AlbumModel', () {
    test('creates AlbumModel with correct fields', () {
      final album = AlbumModel(
        id: '1',
        name: 'Test Album',
        artist: 'Test Artist',
        coverArt: '/path/to/cover.jpg',
        songCount: 10,
      );

      expect(album.id, '1');
      expect(album.name, 'Test Album');
      expect(album.artist, 'Test Artist');
      expect(album.coverArt, '/path/to/cover.jpg');
      expect(album.songCount, 10);
    });
  });

  group('DurationFormatter', () {
    test('formats duration correctly', () {
      expect(DurationFormatter.format(const Duration(seconds: 0)), '00:00');
      expect(DurationFormatter.format(const Duration(seconds: 61)), '01:01');
      expect(DurationFormatter.format(const Duration(seconds: 3661)), '01:01');
    });
  });
}
