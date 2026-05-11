import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/playlist_service.dart';
import '../widgets/song_tile.dart';
import '../utils/duration_formatter.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final PlaylistService _playlistService = PlaylistService();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSongs();
  }

  Future<void> _loadAllSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _sortSongs(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'title':
          _songs.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'artist':
          _songs.sort((a, b) => a.artist.compareTo(b.artist));
          break;
        case 'album':
          _songs.sort((a, b) => (a.album ?? '').compareTo(b.album ?? ''));
          break;
        case 'duration':
          _songs.sort((a, b) {
            final aDur = a.duration?.inMilliseconds ?? 0;
            final bDur = b.duration?.inMilliseconds ?? 0;
            return aDur.compareTo(bDur);
          });
          break;
      }
    });
  }

  Duration _totalDuration() {
    int totalMs = 0;
    for (final song in _songs) {
      totalMs += song.duration?.inMilliseconds ?? 0;
    }
    return Duration(milliseconds: totalMs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        title: const Text('All Songs', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: const Color(0xFF282828),
            onSelected: _sortSongs,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'title', child: Text('Sort by Title', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'artist', child: Text('Sort by Artist', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'album', child: Text('Sort by Album', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'duration', child: Text('Sort by Duration', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : _songs.isEmpty
              ? const Center(
                  child: Text('No songs found', style: TextStyle(color: Colors.grey)),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: const Color(0xFF282828),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${_songs.length} ${_songs.length == 1 ? 'song' : 'songs'}',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '· ${DurationFormatter.format(_totalDuration())}',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFF1DB954),
                        onRefresh: _loadAllSongs,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _songs.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: Color(0xFF282828),
                            indent: 72,
                          ),
                          itemBuilder: (context, index) {
                            final song = _songs[index];
                            return SongTile(
                              song: song,
                              onTap: () {
                                context.read<AudioProvider>().setPlaylist(_songs, index);
                              },
                              onAddToPlaylist: () {
                                _showAddToPlaylistDialog(song);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showAddToPlaylistDialog(SongModel song) {
    final playlistProvider = context.read<PlaylistProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Add to Playlist',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (playlistProvider.playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No playlists yet', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...playlistProvider.playlists.map((playlist) => ListTile(
                    leading: const Icon(Icons.playlist_play, color: Color(0xFF1DB954)),
                    title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${playlist.songIds.length} songs', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () {
                      playlistProvider.addSongToPlaylist(playlist.id, song.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('Added to "${playlist.name}"'),
                          backgroundColor: const Color(0xFF1DB954),
                        ),
                      );
                    },
                  )),
                const Divider(color: Color(0xFF191414)),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: Colors.white),
                  title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreatePlaylistDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF191414),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<PlaylistProvider>().createPlaylist(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create', style: TextStyle(color: Color(0xFF1DB954))),
            ),
          ],
        );
      },
    );
  }
}
