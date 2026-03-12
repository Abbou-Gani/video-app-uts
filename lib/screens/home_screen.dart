import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'video_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Video> videos = [
    Video(
      title: 'Burkina Faso',
      description: 'Decouvrez le beau drapeau du burkina faso',
      duration: '00:30',
      videoPath: 'lib/assets/videos/video1.mp4',
    ),
    Video(
      title: 'La plage',
      description: 'La plage',
      duration: '00:46',
      videoPath: 'lib/assets/videos/video2.mp4',
    ),
    Video(
      title: 'Niger',
      description: 'Decouvrez le beau drapeau du Niger',
      duration: '00:30',
      videoPath: 'lib/assets/videos/video3.mp4',
    ),
    Video(
      title: 'Senegal',
      description: 'Decouvrez le beau drapeau du Senegal',
      duration: '00:20',
      videoPath: 'lib/assets/videos/video4.mp4',
    ),
    Video(
      title: 'Naruto vs Sassuke',
      description: 'Decouvrez un combat digne de fiml d\action ',
      duration: '02:38',
      videoPath: 'lib/assets/videos/video5.mp4',
    ),
    Video(
      title: 'Apprendre flutter ',
      description: 'Apprenez flutter en 15 min',
      duration: '15:48',
      videoPath: 'lib/assets/videos/video6.mp4',
    ),
  ];

  final Map<String, String?> _thumbnails = {};

  @override
  void initState() {
    super.initState();
    _loadAllThumbnails();
  }

  Future<void> _loadAllThumbnails() async {
    final dir = await getTemporaryDirectory();
    for (final video in videos) {
      try {
        // Copier la vidéo depuis assets vers le stockage temporaire
        final byteData = await rootBundle.load(video.videoPath);
        final tempVideoFile = File('${dir.path}/${video.title}.mp4');
        await tempVideoFile.writeAsBytes(byteData.buffer.asUint8List());

        // Générer le thumbnail depuis le fichier temporaire
        final thumb = await VideoThumbnail.thumbnailFile(
          video: tempVideoFile.path,
          thumbnailPath: dir.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 300,
          quality: 80,
        );
        if (mounted) {
          setState(() => _thumbnails[video.videoPath] = thumb);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _thumbnails[video.videoPath] = null);
        }
      }
    }
  }

  Widget _buildThumbnail(String videoPath, {double? width, double? height}) {
    final thumb = _thumbnails[videoPath];
    if (thumb != null) {
      return Image.file(
        File(thumb),
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a4f4a), Color(0xFF2E7D72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.play_circle_fill, color: Colors.white54, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = videos.first;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F1E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎬 VideoApp UTS',
                            style: TextStyle(
                                color: Color(0xFF4CAF9A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(email,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white54),
                      onPressed: () {
                        AuthService.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Featured Video ──
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 380,
                    child: _buildThumbnail(featured.videoPath, height: 380),
                  ),
                  Container(
                    height: 380,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xAA000000),
                          Color(0xFF0D1F1E),
                        ],
                        stops: [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Text(
                          featured.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          featured.description,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow,
                                  color: Colors.black),
                              label: const Text('Lecture',
                                  style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VideoDetailScreen(video: featured),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Ma liste',
                                  style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white54),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Titre section ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Toutes les vidéos',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),

              // ── Liste verticale ──
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoDetailScreen(video: video),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2F2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: _buildThumbnail(video.videoPath,
                                width: 120, height: 80),
                          ),
                          const SizedBox(width: 12),
                          // Infos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  video.description,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '⏱ ${video.duration}',
                                  style: const TextStyle(
                                      color: Color(0xFF4CAF9A), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.play_circle_outline,
                                color: Color(0xFF4CAF9A), size: 28),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}