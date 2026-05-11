import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playback_state_model.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/lyrics_service.dart';
import '../utils/constants.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _showLyrics = false;
  List<LyricsLine> _lyrics = [];
  String? _lastSongId;

  Future<void> _loadLyrics(SongModel song) async {
    final result = await LyricsService.loadLyrics(
      song.filePath,
      song.title,
      song.artist,
      song.duration ?? const Duration(seconds: 180),
    );
    if (mounted && song.id == _lastSongId) {
      setState(() => _lyrics = result);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.secondaryColor,
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No song playing', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          if (song.id != _lastSongId) {
            _lastSongId = song.id;
            _loadLyrics(song);
          }

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, provider),
                Expanded(
                  child: _showLyrics
                      ? _buildLyricsView(provider)
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildAlbumArt(song),
                                const SizedBox(height: 40),
                                _buildSongInfo(song),
                                const SizedBox(height: 40),
                                StreamBuilder<PlaybackState>(
                                  stream: provider.playbackStateStream,
                                  builder: (context, snapshot) {
                                    final state = snapshot.data;
                                    return ProgressBar(
                                      position: state?.position ?? Duration.zero,
                                      duration: state?.duration ?? Duration.zero,
                                      onSeek: (position) {
                                        provider.seek(position);
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                PlayerControls(provider: provider),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AudioProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _showLyrics = !_showLyrics);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _showLyrics ? const Color(0xFF1DB954) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showLyrics ? const Color(0xFF1DB954) : Colors.grey,
                ),
              ),
              child: Text(
                _showLyrics ? 'Lyrics' : 'Now Playing',
                style: TextStyle(
                  color: _showLyrics ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsView(AudioProvider provider) {
    if (_lyrics.isEmpty) {
      return const Center(
        child: Text('No lyrics available', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return _LyricsBody(
      lyrics: _lyrics,
      stream: provider.playbackStateStream,
    );
  }

  Widget _buildAlbumArt(SongModel song) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.albumArtBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.albumArtBorderRadius),
            child: song.albumArt != null
                ? Image.file(File(song.albumArt!), fit: BoxFit.cover)
                : Container(
                    color: AppConstants.cardColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: size * 0.3, color: Colors.grey[700]),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSongInfo(SongModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        if (song.album != null) ...[
          const SizedBox(height: 4),
          Text(
            song.album!,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _LyricsBody extends StatefulWidget {
  final List<LyricsLine> lyrics;
  final Stream<PlaybackState> stream;

  const _LyricsBody({required this.lyrics, required this.stream});

  @override
  State<_LyricsBody> createState() => _LyricsBodyState();
}

class _LyricsBodyState extends State<_LyricsBody> {
  final ScrollController _scrollController = ScrollController();
  int _currentLine = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLine(int index) {
    if (!_scrollController.hasClients) return;
    final offset = (index * 60.0) - (MediaQuery.of(context).size.height / 3);
    _scrollController.jumpTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: widget.stream,
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;
        final posMs = position.inMilliseconds;

        int newLine = 0;
        for (int i = widget.lyrics.length - 1; i >= 0; i--) {
          if (widget.lyrics[i].time.inMilliseconds <= posMs) {
            newLine = i;
            break;
          }
        }

        if (newLine != _currentLine) {
          _currentLine = newLine;
          _scrollToLine(_currentLine);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.lyrics.length,
            itemBuilder: (context, index) {
              final line = widget.lyrics[index];
              final isCurrent = index == _currentLine;
              final isPast = index < _currentLine;

              if (line.text.isEmpty) {
                return const SizedBox(height: 24);
              }

              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isCurrent
                      ? const Color(0xFF1DB954)
                      : isPast
                          ? Colors.grey[600]
                          : Colors.grey[500],
                  fontSize: isCurrent ? 22 : 16,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  height: 1.8,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    line.text,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
