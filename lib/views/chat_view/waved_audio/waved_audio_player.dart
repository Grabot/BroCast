import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../../utils/utils.dart';

class WavedAudioPlayer extends StatefulWidget {
  final String filePath;
  final int messageId;
  final Color playedColor;
  final Color unplayedColor;
  final double barWidth;
  final double spacing;
  final double waveHeight;
  final double waveWidth;

  WavedAudioPlayer({
    super.key,
    required this.filePath,
    required this.messageId,
    this.playedColor = Colors.blue,
    this.unplayedColor = Colors.grey,
    this.barWidth = 2,
    this.spacing = 4,
    this.waveWidth = 200,
    this.waveHeight = 35
  });

  @override
  _WavedAudioPlayerState createState() => _WavedAudioPlayerState();
}

class _WavedAudioPlayerState extends State<WavedAudioPlayer> {
  late AudioPlayer _audioPlayer;
  late PlayerController playerController;
  List<double> waveformData = [];
  Duration audioDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool isPausing = true;
  Uint8List? _audioBytes;
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    playerController = PlayerController();
    _loadWaveform();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    playerController.dispose();
    super.dispose();
  }

  Future<void> _loadWaveform() async {
    try {
      if (_audioBytes == null) {
        _audioBytes = await _loadDeviceFileAudioWaveform(widget.filePath);
        waveformData = await _extractWaveformData(widget.filePath);
        setState(() {});
      }
    } catch (e) {
      showToastMessage("Error loading waveform: $e");
    }
  }

  Future<Uint8List?> _loadDeviceFileAudioWaveform(String filePath) async {
    try {
      final File file = File(filePath);
      final Uint8List audioBytes = await file.readAsBytes();
      return audioBytes;
    } catch (e) {
      showToastMessage("Error loading audio: $e");
    }
    return null;
  }

  void _setupAudioPlayer() {
    _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.file(widget.filePath),
      ),
    );

    _audioPlayer.durationStream.listen((Duration? duration) {
      if (duration != null) {
        setState(() {
          audioDuration = duration;
        });
      }
    });

    _audioPlayer.positionStream.listen((Duration position) {
      setState(() {
        currentPosition = position;
      });
    });

    _audioPlayer.processingStateStream.listen((ProcessingState state) {
      if (state == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
        setState(() {
          isPausing = true;
        });
      }
    });
  }

  String _formatDurationRemaining(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final remainingDuration = audioDuration - duration;
    final hours = remainingDuration.inHours;
    final minutes = twoDigits(remainingDuration.inMinutes.remainder(60));
    final seconds = twoDigits(remainingDuration.inSeconds.remainder(60));

    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  Future<List<double>> _extractWaveformData(String filePath) async {
    final waveformData = await playerController.extractWaveformData(
      path: filePath,
      noOfSamples: widget.waveWidth ~/ (widget.barWidth + widget.spacing),
    );

    return waveformData;
  }

  void _onWaveformTap(double tapX, double width) {
    double tapPercent = tapX / width;
    Duration newPosition = audioDuration * tapPercent;
    _audioPlayer.seek(newPosition);
  }

  void _playAudio() async {
    if (_audioBytes == null) return;
    _audioPlayer.play();
    setState(() {
      isPausing = false;
    });
  }

  void _pauseAudio() async {
    _audioPlayer.pause();
    setState(() {
      isPausing = true;
    });
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
            _formatDurationRemaining(currentPosition),
            style: simpleTextStyle()
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (TapDownDetails details) {
                _onWaveformTap(details.localPosition.dx, widget.waveWidth);
              },
              child: CustomPaint(
                size: Size(widget.waveWidth, widget.waveHeight),
                painter: WaveformPainter(
                    waveformData,
                    currentPosition.inMilliseconds /
                        (audioDuration.inMilliseconds == 0
                            ? 1
                            : audioDuration.inMilliseconds),
                    playedColor: widget.playedColor,
                    unplayedColor: widget.unplayedColor,
                    barWidth: widget.barWidth),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            buttonPressed();
          },
          child: Icon(
            getPlayPauseIcon()
          ),
        )
      ]
    );
  }

  buttonPressed() {
    if (isPausing) {
      _playAudio();
    } else {
      _pauseAudio();
    }
  }

  IconData getPlayPauseIcon() {
    if (isPausing) {
      return Icons.play_arrow;
    } else {
      return Icons.pause;
    }
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  Color playedColor;
  Color unplayedColor;
  double barWidth;

  WaveformPainter(this.waveformData, this.progress,
      {this.playedColor = Colors.blue, this.unplayedColor = Colors.grey, this.barWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = unplayedColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    int playedLines = (waveformData.length * progress).round();

    double maxHeight = size.height;

    for (int i = 0; i < waveformData.length; i++) {
      double x = (size.width / waveformData.length) * i;

      double scaledValue = waveformData[i] * maxHeight;

      double startY = size.height / 2 - scaledValue;
      double endY = size.height / 2 + scaledValue;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint..color = i <= playedLines ? playedColor : unplayedColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}