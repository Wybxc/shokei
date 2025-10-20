import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class ExecutionButton extends StatefulWidget {
  final double size;
  final VoidCallback? onFinished;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;

  const ExecutionButton({
    super.key,
    this.size = 240,
    this.onFinished,
    required this.onPressStart,
    required this.onPressEnd,
  });

  @override
  State<ExecutionButton> createState() => _ExecutionButtonState();
}

class _ExecutionButtonState extends State<ExecutionButton>
    with TickerProviderStateMixin {
  bool _filled = false;
  late AnimationController _progressController;
  late AnimationController _scaleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  final AudioPlayer _holdPlayer = AudioPlayer();
  final AudioPlayer _finishPlayer = AudioPlayer();
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  // Initialize animation controllers
  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 5500),
      vsync: this,
    )..addStatusListener(_onProgressStatusChanged);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  // Progress animation status listener
  void _onProgressStatusChanged(AnimationStatus status) {
    debugPrint('Progress animation status: $status');
    debugPrint(
        'Current progress value: ${_progressController.value}, isHolding: $_isHolding');
    if (status == AnimationStatus.completed &&
        _progressController.value >= 1.0) {
      _onFillComplete();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scaleController.dispose();
    _holdPlayer.dispose();
    _finishPlayer.dispose();
    super.dispose();
  }

  Future<void> _onFillComplete() async {
    setState(() => _filled = true);
    await _stopFeedback();
    await _playAudio(_finishPlayer, 'audio/finished.wav');
    widget.onFinished?.call();
  }

  // Generic audio playback method with unified error handling
  Future<void> _playAudio(AudioPlayer player, String assetPath,
      {ReleaseMode? releaseMode}) async {
    try {
      if (releaseMode != null) {
        await player.setReleaseMode(releaseMode);
      }
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing audio ($assetPath): $e');
    }
  }

  // Generic audio stop method
  Future<void> _stopAudio(AudioPlayer player) async {
    try {
      await player.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  // Start vibration feedback
  Future<void> _startVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Vibrate with pattern: wait 0ms, vibrate 100ms, repeat
        await Vibration.vibrate(pattern: [0, 100], repeat: 0);
      }
    } catch (e) {
      debugPrint('Error starting vibration: $e');
    }
  }

  // Stop vibration feedback
  Future<void> _stopVibration() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      debugPrint('Error stopping vibration: $e');
    }
  }

  // Stop all feedback effects (audio + vibration)
  Future<void> _stopFeedback() async {
    await Future.wait([
      _stopAudio(_holdPlayer),
      _stopVibration(),
    ]);
  }

  void _onPanStart() {
    if (_filled) return;

    widget.onPressStart();
    _isHolding = true;
    _scaleController.forward();
    _startVibration();
    _playAudio(_holdPlayer, 'audio/processing.wav',
        releaseMode: ReleaseMode.loop);
    _progressController.forward();
  }

  void _onPanStop() {
    widget.onPressEnd();
    _isHolding = false;
    _scaleController.reverse();

    if (!_filled) {
      _stopFeedback();
      _resetProgress();
    }
  }

  // Reset progress animation
  void _resetProgress() {
    final currentProgress = _progressController.value;
    _progressController.stop();
    _progressController.animateTo(
      0.0,
      duration: Duration(milliseconds: (currentProgress * 1000).toInt()),
      curve: Curves.linear,
    );
  }

  void _onDoubleTap() {
    if (_filled) {
      _progressController.stop();
      _progressController.reset();
      _stopFeedback();
      widget.onPressEnd();
      setState(() => _filled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _onPanStart(),
      onPanEnd: (details) => _onPanStop(),
      onPanCancel: () => _onPanStop(),
      onDoubleTap: _onDoubleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _progressAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _ShadowPainter(scale: _scaleAnimation.value),
                child: Stack(
                  children: [
                    // Background image
                    _buildButtonImage('assets/images/button_bg.png'),

                    // Fill animation
                    _buildFillAnimation(),

                    // Button foreground
                    _buildButtonImage('assets/images/button.png'),

                    // Finish overlay
                    if (_filled) _buildButtonImage('assets/images/finish.png'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build button image layer
  Widget _buildButtonImage(String assetPath) {
    return ClipOval(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
      ),
    );
  }

  // Build fill animation
  Widget _buildFillAnimation() {
    return ClipOval(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: _progressAnimation.value,
          child: Container(
            color: const Color(0xFF953949),
          ),
        ),
      ),
    );
  }
}

class _ShadowPainter extends CustomPainter {
  final double scale;

  _ShadowPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.78)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 60.0);

    final radius = (size.width / 2) * scale;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShadowPainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}
