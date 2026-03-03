import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class StatusViewScreen extends StatefulWidget {
  final StatusModel status;
  final bool isDarkMode;

  const StatusViewScreen({
    super.key,
    required this.status,
    required this.isDarkMode,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  int _currentIndex = 0;
  double _progress = 0.0;
  Timer? _timer;
  final int _storyDurationInSeconds = 5;

  @override
  void initState() {
    super.initState();
    _startStory();
  }

  void _startStory() {
    _progress = 0.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.05 / _storyDurationInSeconds;
        if (_progress >= 1.0) {
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.status.items.length - 1) {
      setState(() {
        _currentIndex++;
        _startStory();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _startStory();
      });
    } else {
      _startStory(); // Reset current story
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.status.items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Content
            Center(
              child: item.type == StatusType.text
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: _parseColor(item.backgroundColor),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            item.content,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    )
                  : item.type == StatusType.video
                  ? StatusVideoPlayer(videoPath: item.content)
                  : Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: FileImage(File(item.content)),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            ),

            // Progress Bars
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: List.generate(
                    widget.status.items.length,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: index < _currentIndex
                                ? 1.0
                                : (index == _currentIndex ? _progress : 0.0),
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header info
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF6B7B8D),
                      child: Text(
                        widget.status.contactName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.status.contactName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatTime(item.timestamp),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF008069);
    }
  }

  String _formatTime(DateTime time) {
    return 'just now'; // Simulation simplicity
  }
}

class StatusVideoPlayer extends StatefulWidget {
  final String videoPath;
  const StatusVideoPlayer({super.key, required this.videoPath});

  @override
  State<StatusVideoPlayer> createState() => _StatusVideoPlayerState();
}

class _StatusVideoPlayerState extends State<StatusVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
        _controller.setLooping(false);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
