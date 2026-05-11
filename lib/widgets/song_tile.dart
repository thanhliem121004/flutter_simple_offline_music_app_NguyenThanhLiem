import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/album_art.dart';
import '../utils/duration_formatter.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onRemove;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onAddToPlaylist,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AlbumArt(song: song, size: 48),
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          song.artist,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (song.album != null) ...[
                        const Text('  ·  ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Flexible(
                          child: Text(
                            song.album!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              color: const Color(0xFF282828),
              onSelected: (value) {
                switch (value) {
                  case 'add':
                    onAddToPlaylist?.call();
                    break;
                  case 'remove':
                    onRemove?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add',
                  child: ListTile(
                    leading: Icon(Icons.playlist_add, color: Colors.white, size: 20),
                    title: Text('Add to Playlist', style: TextStyle(color: Colors.white, fontSize: 14)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (onRemove != null)
                  const PopupMenuItem(
                    value: 'remove',
                    child: ListTile(
                      leading: Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                      title: Text('Remove', style: TextStyle(color: Colors.red, fontSize: 14)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
