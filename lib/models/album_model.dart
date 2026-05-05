class AlbumModel {
  final String id;
  final String name;
  final String artist;
  final String? coverArt;
  final int songCount;

  AlbumModel({
    required this.id,
    required this.name,
    required this.artist,
    this.coverArt,
    required this.songCount,
  });
}
