import 'dart:io';

class LyricsLine {
  final Duration time;
  final String text;

  LyricsLine({required this.time, required this.text});
}

class LyricsService {
  static Future<List<LyricsLine>> loadLyrics(
    String filePath,
    String title,
    String artist,
    Duration duration,
  ) async {
    final lrcPath = _getLrcPath(filePath);
    if (lrcPath != null) {
      final lrcLines = await _parseLrcFile(lrcPath);
      if (lrcLines.isNotEmpty) return lrcLines;
    }
    return _generatePlaceholder(title, artist, duration);
  }

  static String? _getLrcPath(String audioPath) {
    try {
      final file = File(audioPath);
      final dir = file.parent;
      final name = file.uri.pathSegments.last;
      final dotIndex = name.lastIndexOf('.');
      if (dotIndex == -1) return null;
      final baseName = name.substring(0, dotIndex);
      final lrcFile = File('${dir.path}$baseName.lrc');
      if (lrcFile.existsSync()) return lrcFile.path;
      final lrcAlt = File('${dir.path}$baseName.LRC');
      if (lrcAlt.existsSync()) return lrcAlt.path;
    } catch (_) {}
    return null;
  }

  static Future<List<LyricsLine>> _parseLrcFile(String path) async {
    final lines = <LyricsLine>[];
    try {
      final content = await File(path).readAsString();
      final rawLines = content.split('\n');

      for (final rawLine in rawLines) {
        final trimmed = rawLine.trim();
        if (trimmed.isEmpty) continue;

        final tagMatch = RegExp(r'^\[(ti|ar|al|by|offset):(.*)\]$').firstMatch(trimmed);
        if (tagMatch != null) continue;

        final timestamps = RegExp(r'\[(\d{2}):(\d{2})[\.:](\d{2,3})\]').allMatches(trimmed);
        if (timestamps.isEmpty) continue;

        final text = trimmed.replaceAll(RegExp(r'\[.*?\]'), '').trim();
        if (text.isEmpty) continue;

        for (final match in timestamps) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final millis = int.parse(match.group(3)!.padRight(3, '0').substring(0, 3));
          lines.add(LyricsLine(
            time: Duration(minutes: minutes, seconds: seconds, milliseconds: millis),
            text: text,
          ));
        }
      }

      lines.sort((a, b) => a.time.compareTo(b.time));
    } catch (_) {}
    return lines;
  }

  static List<LyricsLine> _generatePlaceholder(String title, String artist, Duration duration) {
    final lines = <LyricsLine>[];
    final totalSeconds = duration.inSeconds;

    if (totalSeconds <= 0) {
      return [LyricsLine(time: Duration.zero, text: '♪ $title ♪')];
    }

    final segments = <List<String>>[
      [
        '♪ $title ♪',
        '♪ By $artist ♪',
        '',
      ],
      [
        'Wandering through the silent night',
        'Looking for a guiding light',
        'Every step I take alone',
        'Finding my way back home',
      ],
      [
        'The stars above begin to shine',
        'Telling me that you\'ll be mine',
        'In this moment, time stands still',
        'Nothing else can break this spell',
      ],
      [
        'And I sing, la la la la la',
        'Can you hear my voice tonight',
        'Through the silence, through the dark',
        'You will always be the light',
      ],
      [
        'When the morning comes around',
        'I will always be spellbound',
        'Every memory we made',
        'In the sunlight starts to fade',
      ],
      [
        'Oh, we dance beneath the moon',
        'To a sweet and simple tune',
        'Nothing else compares to you',
        'Every word I say is true',
      ],
      [
        'And I sing, la la la la la',
        'Can you hear my voice tonight',
        'Through the silence, through the dark',
        'You will always be the light',
      ],
      [
        '',
        '♪ $title ♪',
        '♪ Performed by $artist ♪',
        '♪ ♪ ♪',
      ],
    ];

    final chunkSize = totalSeconds ~/ segments.length;
    var currentSec = 0;

    for (final segment in segments) {
      final segDuration = segment.isEmpty
          ? chunkSize
          : (segment.length * (chunkSize ~/ (segment.length + 1)).clamp(2, 12));
      var lineDuration = (segDuration ~/ (segment.length + 1)).clamp(2, 10);

      for (final lineText in segment) {
        if (currentSec >= totalSeconds) break;
        lines.add(LyricsLine(
          time: Duration(seconds: currentSec),
          text: lineText,
        ));
        currentSec += lineDuration;
      }
      if (currentSec >= totalSeconds) break;
    }

    if (lines.isEmpty) {
      lines.add(LyricsLine(time: Duration.zero, text: '♪ $title ♪'));
    }

    return lines;
  }
}
