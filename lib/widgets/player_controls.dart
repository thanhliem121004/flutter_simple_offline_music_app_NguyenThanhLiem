import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: provider.isShuffleEnabled ? const Color(0xFF1DB954) : Colors.grey,
                size: 24,
              ),
              onPressed: () => provider.toggleShuffle(),
            ),
            const SizedBox(width: 40),
            _buildRepeatButton(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36),
              onPressed: () => provider.previous(),
            ),
            const SizedBox(width: 24),
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return InkWell(
                  onTap: () => provider.playPause(),
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1DB954),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x401DB954),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36),
              onPressed: () => provider.next(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepeatButton() {
    IconData icon;
    Color color;

    switch (provider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = Colors.grey;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = const Color(0xFF1DB954);
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = const Color(0xFF1DB954);
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color, size: 24),
      onPressed: () => provider.toggleRepeat(),
    );
  }
}
