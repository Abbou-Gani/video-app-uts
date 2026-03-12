import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video.dart';

class VideoDetailScreen extends StatefulWidget {
  final Video video;
  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video.videoPath)
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F1E),
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Lecteur vidéo
            GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: Container(
                width: double.infinity,
                height: 220,
                color: Colors.black,
                child: _isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                          // Overlay contrôles
                          if (_showControls)
                            Container(
                              color: Colors.black38,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    iconSize: 36,
                                    icon: const Icon(Icons.replay_10,
                                        color: Colors.white),
                                    onPressed: () {
                                      final pos = _controller.value.position;
                                      _controller.seekTo(
                                          pos - const Duration(seconds: 10));
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF5A623),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      iconSize: 36,
                                      icon: Icon(
                                        _controller.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _controller.value.isPlaying
                                              ? _controller.pause()
                                              : _controller.play();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    iconSize: 36,
                                    icon: const Icon(Icons.forward_10,
                                        color: Colors.white),
                                    onPressed: () {
                                      final pos = _controller.value.position;
                                      _controller.seekTo(
                                          pos + const Duration(seconds: 10));
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF4CAF9A))),
              ),
            ),

            // Barre de progression
            if (_isInitialized)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFFF5A623),
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Temps
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(value.position),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11),
                            ),
                            Text(
                              _formatDuration(value.duration),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Infos vidéo
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A2F2E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Titre + durée
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.video.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF9A).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF4CAF9A)),
                          ),
                          child: Text(
                            '⏱ ${widget.video.duration}',
                            style: const TextStyle(
                                color: Color(0xFF4CAF9A), fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Color(0xFF4CAF9A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}