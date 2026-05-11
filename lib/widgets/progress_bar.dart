import 'package:flutter/material.dart';
import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SliderTheme(
          data: theme.sliderTheme.copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.grey[700],
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble().clamp(1, double.infinity)),
            min: 0.0,
            max: duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
            onChanged: (value) {
              onSeek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(position),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                DurationFormatter.format(duration),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
