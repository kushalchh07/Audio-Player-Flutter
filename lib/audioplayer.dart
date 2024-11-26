import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _playerState = state;
      });
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Playback controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_playerState == PlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow),
              onPressed: () {
                _playerState == PlayerState.playing
                    ? _pauseAudio()
                    : _playAudio();
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopAudio,
            ),
          ],
        ),
        // Progress slider
        Slider(
          value: _position.inSeconds.toDouble(),
          max: _duration.inSeconds.toDouble(),
          onChanged: (double value) {
            _audioPlayer.seek(Duration(seconds: value.toInt()));
          },
        ),
        // Time display
        Text(
          '${_position.toString().split('.').first} / ${_duration.toString().split('.').first}',
        ),
      ],
    );
  }
}

// Usage in another widget
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AudioPlayerWidget(
        audioUrl: 'https://jlptmocktest.com/file/1732517990_question 9.mp3',
      ),
    );
  }
}
