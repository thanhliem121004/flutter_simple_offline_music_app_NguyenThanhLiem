import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../services/sample_song_service.dart';
import '../widgets/mini_player.dart';
import '../utils/duration_formatter.dart';
import 'all_songs_screen.dart';
import 'playlist_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();
  final SampleSongService _sampleSongService = SampleSongService();

  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    _hasPermission = await _permissionService.requestMediaPermission();

    if (_hasPermission) {
      await _loadDeviceSongs();
    }

    if (_songs.isEmpty) {
      await _loadSampleSongs();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDeviceSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      if (mounted) {
        setState(() {
          _songs = songs;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error loading device songs: $e');
      }
    }
  }

  Future<void> _loadSampleSongs() async {
    try {
      final samples = await _sampleSongService.loadSampleSongs();
      if (mounted && samples.isNotEmpty) {
        setState(() {
          _songs = samples;
        });
      }
    } catch (e) {
      debugPrint('Error loading sample songs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildQuickActions(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1DB954),
                      ),
                    )
                  : !_hasPermission
                      ? _buildPermissionDenied()
                      : _songs.isEmpty
                          ? _buildNoSongs()
                          : RefreshIndicator(
                              color: const Color(0xFF1DB954),
                              onRefresh: _loadDeviceSongs,
                              child: _buildSongList(),
                            ),
            ),
            Consumer<AudioProvider>(
              builder: (context, provider, child) {
                if (provider.currentSong == null) return const SizedBox.shrink();
                return const MiniPlayer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.music_note, color: Color(0xFF1DB954), size: 32),
              SizedBox(width: 8),
              Text(
                'Music Player',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildActionChip(Icons.library_music, 'All Songs', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllSongsScreen()),
            );
          }),
          const SizedBox(width: 8),
          _buildActionChip(Icons.playlist_play, 'Playlists', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlaylistScreen()),
            );
          }),
          const SizedBox(width: 8),
          _buildActionChip(Icons.search, 'Search', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF1DB954), size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _songs.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        color: Color(0xFF282828),
        indent: 72,
      ),
      itemBuilder: (context, index) {
        final song = _songs[index];
        return InkWell(
          onTap: () {
            context.read<AudioProvider>().setPlaylist(_songs, index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note, color: Colors.grey),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (song.duration != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      DurationFormatter.format(song.duration!),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.music_off, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Storage Permission Required',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please grant storage permission\nto access your music files',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final granted = await _permissionService.requestMediaPermission();
                if (mounted) {
                  setState(() {
                    _hasPermission = granted;
                  });
                  if (granted) {
                    await _loadDeviceSongs();
                  }
                  if (_songs.isEmpty) {
                    await _loadSampleSongs();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Grant Permission', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.music_note, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Music Found',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some music files to your device\nor load sample songs',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await _loadSampleSongs();
              if (mounted) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.music_note, size: 18),
            label: const Text('Load Sample Songs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


