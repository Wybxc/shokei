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
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 5500),
      vsync: this,
    );
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

    _progressController.addStatusListener((status) {
      debugPrint('Progress animation status: $status');
      debugPrint(
          'Current progress value: ${_progressController.value}, isHolding: $_isHolding');
      if (status == AnimationStatus.completed &&
          _progressController.value >= 1.0) {
        _onFillComplete();
      }
    });
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
    await _stopHoldSound();
    await _stopVibration();
    await _playFinishSound();
    widget.onFinished?.call();
  }

  Future<void> _playHoldSound() async {
    try {
      await _holdPlayer.setReleaseMode(ReleaseMode.loop);
      await _holdPlayer.play(AssetSource('audio/processing.wav'));
    } catch (e) {
      debugPrint('Error playing hold sound: $e');
    }
  }

  Future<void> _stopHoldSound() async {
    try {
      await _holdPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping hold sound: $e');
    }
  }

  Future<void> _playFinishSound() async {
    try {
      await _finishPlayer.play(AssetSource('audio/finished.wav'));
    } catch (e) {
      debugPrint('Error playing finish sound: $e');
    }
  }

  Future<void> _startVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        // Vibrate with pattern: wait 0ms, vibrate 100ms, repeat
        await Vibration.vibrate(pattern: [0, 100], repeat: 0);
      }
    } catch (e) {
      debugPrint('Error starting vibration: $e');
    }
  }

  Future<void> _stopVibration() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      debugPrint('Error stopping vibration: $e');
    }
  }

  void _onPanStart() {
    if (_filled) return;

    widget.onPressStart();
    _isHolding = true;
    _scaleController.forward();
    _startVibration();
    _playHoldSound();
    _progressController.forward();
  }

  void _onPanStop() {
    widget.onPressEnd();
    _isHolding = false;
    _scaleController.reverse();

    if (!_filled) {
      _stopHoldSound();
      _stopVibration();

      final currentProgress = _progressController.value;
      _progressController.stop();
      _progressController.animateTo(
        0.0,
        duration: Duration(milliseconds: (currentProgress * 1000).toInt()),
        curve: Curves.linear,
      );
    }
  }

  void _onDoubleTap() {
    if (_filled) {
      _progressController.stop();
      _progressController.reset();
      _stopHoldSound();
      _stopVibration();
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
                    ClipOval(
                      child: Image.asset(
                        'assets/images/button_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Fill animation
                    ClipOval(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: _progressAnimation.value,
                          child: Container(
                            color: const Color(0xFF953949),
                          ),
                        ),
                      ),
                    ),

                    // Button foreground
                    ClipOval(
                      child: Image.asset(
                        'assets/images/button.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Finish overlay
                    if (_filled)
                      ClipOval(
                        child: Image.asset(
                          'assets/images/finish.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
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
