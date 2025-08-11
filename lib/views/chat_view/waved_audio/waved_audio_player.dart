import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/utils.dart';


class WavedAudioPlayer extends StatefulWidget {
  final Source source;
  final int messageId;
  final Color playedColor;
  final Color unplayedColor;
  final double barWidth;
  final double spacing;
  final double waveHeight;
  final double waveWidth;

  WavedAudioPlayer({
    super.key,
    required this.source,
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
  List<double> waveformData = [];
  Duration audioDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool isPausing = true;
  Uint8List? _audioBytes;
  bool released = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(
        playerId: "player_${widget.messageId}"
    );
    print("audio player initialized");
    _loadWaveform();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.release();
    released = true;
    _audioPlayer.dispose();
    isPausing = true;
    super.dispose();
  }

  Future<void> _loadWaveform() async {
    try {
      if (_audioBytes == null) {
        _audioBytes = await _loadDeviceFileAudioWaveform((widget.source as DeviceFileSource).path);
        waveformData = _extractWaveformData(_audioBytes!);
        setState(() {});
      }
      _audioPlayer.setSourceAsset((widget.source as DeviceFileSource).path);
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
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        setState(() {
          isPausing = false;
        });
      } else if (state == PlayerState.paused) {
        setState(() {
          isPausing = true;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _audioPlayer.release();
      released = true;
      currentPosition = Duration.zero;
      setState(() {
        isPausing = true;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        audioDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
      });
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

  List<double> _extractWaveformData(Uint8List audioBytes) {
    List<double> waveData = [];
    int step = (audioBytes.length /
            (widget.waveWidth / (widget.barWidth + widget.spacing)))
        .floor();
    for (int i = 0; i < audioBytes.length; i += step) {
      waveData.add(audioBytes[i] / 255);
    }
    waveData.add(audioBytes[audioBytes.length - 1] / 255);
    return waveData;
  }

  void _onWaveformTap(double tapX, double width) {
    double tapPercent = tapX / width;
    Duration newPosition = audioDuration * tapPercent;
    _audioPlayer.seek(newPosition);
  }

  void _playAudio() async {
    if (_audioBytes == null) return;
    if (released) {
      released = false;
      _audioPlayer.play(BytesSource(_audioBytes!,mimeType: widget.source.mimeType));
    } else {
      _audioPlayer.resume();
    }
    setState(() {});
  }

  void _pauseAudio() async {
    _audioPlayer.pause();
    isPausing = true;
    setState(() {});
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
                    barWidth: widget.barWidth), // Use your wave data
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
      {this.playedColor = Colors.blue, this.unplayedColor = Colors.grey,this.barWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = unplayedColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    int playedLines = (waveformData.length * progress).round();

    double middleY = size.height ;

    for (int i = 0; i < waveformData.length; i++) {
      double x = (size.width / waveformData.length) * i;
      double y = middleY - (waveformData[i] * middleY);
      canvas.drawLine(Offset(x, middleY - (y)), Offset(x, y),
          paint..color = i <= playedLines ? playedColor : unplayedColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
