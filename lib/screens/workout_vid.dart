import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class WorkoutVideoPage extends StatefulWidget {
  final String videoPath;
  const WorkoutVideoPage({super.key, required this.videoPath});

  @override
  State<WorkoutVideoPage> createState() => _WorkoutVideoPageState();
}

class _WorkoutVideoPageState extends State<WorkoutVideoPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _enterLandscapeMode();

    // Use VideoPlayerController.networkUrl with Uri.parse
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (!_controller.value.hasError) {
        _controller.play();
      }
      setState(() {});
    });

    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitLandscapeMode();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _enterLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitLandscapeMode() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  // Called when the user interacts with the video.
  void _onUserInteraction() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  // Seek by the given offset.
  void _seekBy(Duration offset) {
    final newPosition = _controller.value.position + offset;
    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MouseRegion(
              onHover: (event) => _onUserInteraction(),
              child: GestureDetector(
                onTap: _onUserInteraction,
                child: Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    if (_showControls)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Stack(
                            children: [
                              // Exit button.
                              Positioned(
                                top: 40,
                                left: 20,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 30),
                                  tooltip: 'Back to Workout Library',
                                ),
                              ),
                              // Playback controls.
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _seekBy(const Duration(seconds: -10)),
                                      icon: const Icon(Icons.replay_10,
                                          color: Colors.white, size: 36),
                                      tooltip: 'Rewind 10 seconds',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _controller.value.isPlaying
                                              ? _controller.pause()
                                              : _controller.play();
                                        });
                                      },
                                      icon: Icon(
                                        _controller.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      tooltip: 'Play/Pause',
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _seekBy(const Duration(seconds: 10)),
                                      icon: const Icon(Icons.forward_10,
                                          color: Colors.white, size: 36),
                                      tooltip: 'Forward 10 seconds',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading video: ${_controller.value.errorDescription}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
