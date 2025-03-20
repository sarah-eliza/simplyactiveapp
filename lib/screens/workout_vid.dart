import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class WorkoutVideoPage extends StatefulWidget {
  final String videoPath;
  const WorkoutVideoPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  _WorkoutVideoPageState createState() => _WorkoutVideoPageState();
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

    _controller = VideoPlayerController.network(widget.videoPath);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (!_controller.value.hasError) {
        _controller.play();
      } else {
        print("Video Error: ${_controller.value.errorDescription}");
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
    _hideControlsTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  // Called when user interacts (clicks or hovers)
  void _onUserInteraction() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  // Seek by a given offset; updated to 10 seconds.
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
                              // Exit button (top-left)
                              Positioned(
                                top: 40,
                                left: 20,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back,
                                      color: Colors.white, size: 30),
                                  tooltip: 'Back to Workout Library',
                                ),
                              ),
                              // Playback controls (bottom center)
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Rewind 10 seconds button
                                    IconButton(
                                      onPressed: () =>
                                          _seekBy(Duration(seconds: -10)),
                                      icon: Icon(Icons.replay_10, // Use replay_10 icon as proxy
                                          color: Colors.white, size: 36),
                                      tooltip: 'Rewind 10 seconds',
                                    ),
                                    // Play/Pause toggle
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
                                    // Forward 10 seconds button
                                    IconButton(
                                      onPressed: () =>
                                          _seekBy(Duration(seconds: 10)),
                                      icon: Icon(Icons.forward_10, // Use forward_10 icon as proxy
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
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
