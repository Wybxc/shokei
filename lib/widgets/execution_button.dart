import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class ExecutionButton extends HookWidget {
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
  Widget build(BuildContext context) {
    final filled = useState(false);
    final isHolding = useRef(false);

    final progressController = useAnimationController(
      duration: const Duration(milliseconds: 5500),
    );

    final scaleController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );

    final progressAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: progressController, curve: Curves.linear),
      ),
      [progressController],
    );

    final scaleAnimation = useMemoized(
      () => Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
      ),
      [scaleController],
    );

    final holdPlayer = useMemoized(() => AudioPlayer());
    final finishPlayer = useMemoized(() => AudioPlayer());

    // Dispose audio players
    useEffect(() {
      return () {
        holdPlayer.dispose();
        finishPlayer.dispose();
      };
    }, []);

    // Generic audio playback method with unified error handling
    Future<void> playAudio(AudioPlayer player, String assetPath,
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
    Future<void> stopAudio(AudioPlayer player) async {
      try {
        await player.stop();
      } catch (e) {
        debugPrint('Error stopping audio: $e');
      }
    }

    // Start vibration feedback
    Future<void> startVibration() async {
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
    Future<void> stopVibration() async {
      try {
        await Vibration.cancel();
      } catch (e) {
        debugPrint('Error stopping vibration: $e');
      }
    }

    // Stop all feedback effects (audio + vibration)
    Future<void> stopFeedback() async {
      await Future.wait([
        stopAudio(holdPlayer),
        stopVibration(),
      ]);
    }

    Future<void> onFillComplete() async {
      filled.value = true;
      await stopFeedback();
      await playAudio(finishPlayer, 'audio/finished.wav');
      onFinished?.call();
    }

    // Progress animation status listener
    useEffect(() {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed &&
            progressController.value >= 1.0) {
          onFillComplete();
        }
      }

      progressController.addStatusListener(listener);
      return () => progressController.removeStatusListener(listener);
    }, [progressController]);

    void onPanStart() {
      if (filled.value) return;

      onPressStart();
      isHolding.value = true;
      scaleController.forward();
      startVibration();
      playAudio(holdPlayer, 'audio/processing.wav',
          releaseMode: ReleaseMode.loop);
      progressController.forward();
    }

    void onPanStop() {
      onPressEnd();
      isHolding.value = false;
      scaleController.reverse();

      if (!filled.value) {
        stopFeedback();
        // Reset progress animation
        final currentProgress = progressController.value;
        progressController.stop();
        progressController.animateTo(
          0.0,
          duration: Duration(milliseconds: (currentProgress * 1000).toInt()),
          curve: Curves.linear,
        );
      }
    }

    void onDoubleTap() {
      if (filled.value) {
        progressController.stop();
        progressController.reset();
        stopFeedback();
        onPressEnd();
        filled.value = false;
      }
    }

    return GestureDetector(
      onPanDown: (details) => onPanStart(),
      onPanEnd: (details) => onPanStop(),
      onPanCancel: () => onPanStop(),
      onDoubleTap: onDoubleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([scaleAnimation, progressAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _ShadowPainter(scale: scaleAnimation.value),
                child: Stack(
                  children: [
                    // Background image
                    _buildButtonImage('assets/images/button_bg.png'),

                    // Fill animation
                    ClipOval(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: progressAnimation.value,
                          child: Container(
                            color: const Color(0xFF953949),
                          ),
                        ),
                      ),
                    ),

                    // Button foreground
                    _buildButtonImage('assets/images/button.png'),

                    // Finish overlay
                    if (filled.value)
                      _buildButtonImage('assets/images/finish.png'),
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
}

class _ShadowPainter extends CustomPainter {
  final double scale;

  _ShadowPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha((0.78 * 255).toInt())
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
