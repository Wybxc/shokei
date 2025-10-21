import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Resource preloader service that manages audio and image preloading with progress tracking
class ResourcePreloader extends ChangeNotifier {
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, bool> _loadedStatus = {};
  double _progress = 0.0;
  bool _isLoading = false;
  String? _currentFile;
  String _currentType = '';

  double get progress => _progress;
  bool get isLoading => _isLoading;
  String? get currentFile => _currentFile;
  String get currentType => _currentType;
  bool get isComplete => _progress >= 1.0;

  /// List of audio files to preload
  static const List<String> audioFiles = [
    'audio/processing.wav',
    'audio/finished.wav',
  ];

  /// List of image files to preload
  static const List<String> imageFiles = [
    'assets/images/background.jpg',
    'assets/images/button.png',
    'assets/images/button_bg.png',
    'assets/images/finish.png',
    'assets/images/logo.png',
  ];

  /// Preload all resources (audio + images)
  Future<void> preloadAll(BuildContext context) async {
    _isLoading = true;
    _progress = 0.0;
    notifyListeners();

    final totalFiles = audioFiles.length + imageFiles.length;
    int loadedCount = 0;

    // Preload images
    _currentType = 'Image';
    for (final file in imageFiles) {
      _currentFile = file;
      notifyListeners();

      try {
        // Check if context is still mounted before using it
        if (context.mounted) {
          await _preloadImage(file, context);
          _loadedStatus[file] = true;
        }
      } catch (e) {
        debugPrint('Error preloading image $file: $e');
        _loadedStatus[file] = false;
      }

      loadedCount++;
      _progress = loadedCount / totalFiles;
      notifyListeners();

      // Small delay to make progress visible
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Preload audio
    _currentType = 'Audio';
    for (final file in audioFiles) {
      _currentFile = file;
      notifyListeners();

      try {
        await _preloadAudio(file);
        _loadedStatus[file] = true;
      } catch (e) {
        debugPrint('Error preloading audio $file: $e');
        _loadedStatus[file] = false;
      }

      loadedCount++;
      _progress = loadedCount / totalFiles;
      notifyListeners();

      // Small delay to make progress visible
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _isLoading = false;
    _currentFile = null;
    _currentType = '';
    notifyListeners();
  }

  /// Preload a single image file
  Future<void> _preloadImage(String assetPath, BuildContext context) async {
    final imageProvider = AssetImage(assetPath);

    // Use precacheImage which handles context properly
    if (!context.mounted) return;
    await precacheImage(imageProvider, context);
  }

  /// Preload a single audio file
  Future<void> _preloadAudio(String assetPath) async {
    final player = AudioPlayer();

    // Set low volume to avoid audio glitch
    await player.setVolume(0.0);

    // Play the audio file briefly to cache it
    await player.play(AssetSource(assetPath));

    // Wait a bit for the audio to load
    await Future.delayed(const Duration(milliseconds: 200));

    // Stop and reset
    await player.stop();
    await player.setVolume(1.0);

    // Store the player for reuse
    _audioPlayers[assetPath] = player;
  }

  /// Get a preloaded audio player for the given asset path
  AudioPlayer? getAudioPlayer(String assetPath) {
    return _audioPlayers[assetPath];
  }

  /// Create a new audio player for the given asset (for independent playback)
  AudioPlayer createAudioPlayer(String assetPath) {
    return AudioPlayer();
  }

  /// Check if a file is loaded
  bool isFileLoaded(String path) {
    return _loadedStatus[path] == true;
  }

  /// Dispose all players
  @override
  void dispose() {
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    _loadedStatus.clear();
    super.dispose();
  }
}
