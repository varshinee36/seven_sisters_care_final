import 'dart:async';
import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/voice_service.dart';

class MusicTrackPlaceholder {
  final String id;
  final String title;
  final String regionArtist;
  final String durationText;
  final int durationSeconds;
  final String coverAssetPath;
  final Color themeColor;
  final String? audioAssetPath;

  const MusicTrackPlaceholder({
    required this.id,
    required this.title,
    required this.regionArtist,
    required this.durationText,
    required this.durationSeconds,
    required this.coverAssetPath,
    required this.themeColor,
    this.audioAssetPath,
  });
}

class MusicActivityScreen extends StatefulWidget {
  const MusicActivityScreen({super.key});

  @override
  State<MusicActivityScreen> createState() => _MusicActivityScreenState();
}

class _MusicActivityScreenState extends State<MusicActivityScreen> {
  List<MusicTrackPlaceholder> _getPlaylist(BuildContext context) {
    final loc = context.loc;
    return [
      MusicTrackPlaceholder(
        id: "track_1",
        title: loc.translate('track1Title'),
        regionArtist: loc.translate('track1Artist'),
        durationText: "03:45",
        durationSeconds: 225,
        coverAssetPath: "assets/images/m_usic.jpg",
        themeColor: const Color(0xFFD0456E),
        audioAssetPath: "assets/audio/ner_bihu_folk_placeholder.mp3",
      ),
      MusicTrackPlaceholder(
        id: "track_2",
        title: loc.translate('track2Title'),
        regionArtist: loc.translate('track2Artist'),
        durationText: "04:12",
        durationSeconds: 252,
        coverAssetPath: "assets/images/music.jpg",
        themeColor: const Color(0xFF459B98),
        audioAssetPath: "assets/audio/ner_flute_serenade_placeholder.mp3",
      ),
      MusicTrackPlaceholder(
        id: "track_3",
        title: loc.translate('track3Title'),
        regionArtist: loc.translate('track3Artist'),
        durationText: "03:20",
        durationSeconds: 200,
        coverAssetPath: "assets/images/background.jpg",
        themeColor: const Color(0xFFD6BA5F),
        audioAssetPath: "assets/audio/ner_khasi_breeze_placeholder.mp3",
      ),
      MusicTrackPlaceholder(
        id: "track_4",
        title: loc.translate('track4Title'),
        regionArtist: loc.translate('track4Artist'),
        durationText: "04:50",
        durationSeconds: 290,
        coverAssetPath: "assets/images/activities.jpg",
        themeColor: const Color(0xFF4C9866),
        audioAssetPath: "assets/audio/ner_mizo_lullaby_placeholder.mp3",
      ),
    ];
  }

  int _currentTrackIndex = 0;
  bool _isPlaying = false;
  int _currentPositionSeconds = 0;
  Timer? _playbackTimer;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause(List<MusicTrackPlaceholder> playlist) {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startPlaybackTimer(playlist);
      final currentTrack = playlist[_currentTrackIndex];
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.playingTrack(currentTrack.title)),
          backgroundColor: const Color(0xFFD0456E),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _playbackTimer?.cancel();
    }
  }

  void _startPlaybackTimer(List<MusicTrackPlaceholder> playlist) {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final currentTrack = playlist[_currentTrackIndex];
      setState(() {
        if (_currentPositionSeconds < currentTrack.durationSeconds) {
          _currentPositionSeconds++;
        } else {
          _currentPositionSeconds = 0;
          _isPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  void _selectTrack(int index, List<MusicTrackPlaceholder> playlist) {
    _playbackTimer?.cancel();
    setState(() {
      _currentTrackIndex = index;
      _currentPositionSeconds = 0;
      _isPlaying = true;
    });
    _startPlaybackTimer(playlist);
  }

  void _nextTrack(List<MusicTrackPlaceholder> playlist) {
    _selectTrack((_currentTrackIndex + 1) % playlist.length, playlist);
  }

  void _previousTrack(List<MusicTrackPlaceholder> playlist) {
    _selectTrack((_currentTrackIndex - 1 + playlist.length) % playlist.length, playlist);
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _getPlaylist(context);
    if (_currentTrackIndex >= playlist.length) {
      _currentTrackIndex = 0;
    }
    final currentTrack = playlist[_currentTrackIndex];
    final double screenWidth = MediaQuery.of(context).size.width;
    final loc = context.loc;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 600 ? 500 : double.infinity,
            margin: screenWidth > 600
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 30 : 0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Top Header: Logo + Title + Voice Icon
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFFD0456E),
                              child: Icon(Icons.music_note, color: Colors.white, size: 28),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.listeningToMusic,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD0456E),
                              ),
                            ),
                            Text(
                              loc.northEastFolkMelodies,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 30, color: Color(0xFFD0456E)),
                        onPressed: () {
                          VoiceService.instance.speak(
                            loc.musicVoiceGuidance,
                            context: context,
                            themeColor: const Color(0xFFD0456E),
                          );
                        },
                        tooltip: 'Voice Guidance',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Scrollable Player & Playlist Body
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Main Player Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFD0456E),
                                const Color(0xFFD0456E).withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD0456E).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Song Cover Art Placeholder
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    currentTrack.coverAssetPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.music_note_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Track Title & Region
                              Text(
                                currentTrack.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                currentTrack.regionArtist,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Progress Slider
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: Colors.white,
                                ),
                                child: Slider(
                                  value: _currentPositionSeconds
                                      .toDouble()
                                      .clamp(
                                          0.0,
                                          currentTrack.durationSeconds
                                              .toDouble()),
                                  max: currentTrack.durationSeconds.toDouble(),
                                  onChanged: (val) {
                                    setState(() {
                                      _currentPositionSeconds = val.toInt();
                                    });
                                  },
                                ),
                              ),

                              // Timer Display
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_currentPositionSeconds),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      currentTrack.durationText,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Playback Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.skip_previous_rounded,
                                        size: 32,
                                        color: Colors.white),
                                    onPressed: () => _previousTrack(playlist),
                                  ),
                                  const SizedBox(width: 14),
                                  InkWell(
                                    onTap: () => _togglePlayPause(playlist),
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      width: 54,
                                      height: 54,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 34,
                                        color: const Color(0xFFD0456E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next_rounded,
                                        size: 32, color: Colors.white),
                                    onPressed: () => _nextTrack(playlist),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Playlist Section Header
                        Text(
                          loc.playlistNERHeader,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Playlist Cards
                        ...List.generate(playlist.length, (index) {
                          final track = playlist[index];
                          final isSelected = index == _currentTrackIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectTrack(index, playlist),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFD0456E)
                                            .withValues(alpha: 0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFD0456E)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: isSelected
                                            ? const Color(0xFFD0456E)
                                            : Colors.grey.shade200,
                                        child: Icon(
                                          isSelected && _isPlaying
                                              ? Icons.volume_up_rounded
                                              : Icons.music_note_rounded,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              track.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? const Color(0xFFD0456E)
                                                    : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              track.regionArtist,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        track.durationText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFFD0456E)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19D3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF19D3F3),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                loc.backToActivities,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

