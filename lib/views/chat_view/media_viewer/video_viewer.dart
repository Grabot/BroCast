import 'dart:io';

import "package:flutter/material.dart";
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoViewer extends StatefulWidget {
  final String videoFilePath;

  VideoViewer({
    required Key key,
    required this.videoFilePath
  }) : super(key: key);

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  void _initializeVideoController() {
    final file = File(widget.videoFilePath);
    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            autoPlay: true,
            looping: false,
            showControlsOnInitialize: false,
            materialProgressColors: ChewieProgressColors(
                  playedColor: Colors.red,
              handleColor: Colors.red,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey.withValues(alpha: 0.5),
                ),
            placeholder: Center(child: CircularProgressIndicator()),
            autoInitialize: false,
          );
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void backButtonFunctionality() {
    Navigator.pop(context);
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        backButtonFunctionality();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
                },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
              backButtonFunctionality();
                },
              ),
          title: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Video Viewer",
              style: TextStyle(color: Colors.white)
            )
          ),
          actions: [
            PopupMenuButton<int>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (item) => onSelect(context, item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Text("Back to Chat")),
              ]
            ),
          ],
        ),
        body: Center(
            child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : CircularProgressIndicator(),
        )
      ),
    );
  }
}
