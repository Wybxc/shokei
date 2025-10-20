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
    final progress = useState(0.0);
    final scale = useState(1.0);

    final progressController = useAnimationController(
      duration: const Duration(milliseconds: 5500),
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

    // Listen to progress animation changes
    useEffect(() {
      void listener() {
        progress.value = progressController.value;
      }

      progressController.addListener(listener);
      return () => progressController.removeListener(listener);
    }, [progressController]);

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
      scale.value = 0.94;
      startVibration();
      playAudio(holdPlayer, 'audio/processing.wav',
          releaseMode: ReleaseMode.loop);
      progressController.forward();
    }

    void onPanStop() {
      onPressEnd();
      isHolding.value = false;
      scale.value = 1.0;

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
      child: AnimatedScale(
        scale: scale.value,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ShadowPainter(scale: scale.value),
            child: Stack(
              children: [
                // Background image
                _buildButtonImage('assets/images/button_bg.png'),

                // Fill animation
                ClipOval(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedFractionallySizedBox(
                      heightFactor: progress.value,
                      duration: Duration
                          .zero, // No additional animation, follows controller
                      child: Container(
                        color: const Color(0xFF953949),
                      ),
                    ),
                  ),
                ),

                // Button foreground
                _buildButtonImage('assets/images/button.png'),

                // Finish overlay with fade-in animation
                AnimatedOpacity(
                  opacity: filled.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _buildButtonImage('assets/images/finish.png'),
                ),
              ],
            ),
          ),
        ),
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

// Custom widget for animated fractionally sized box
class AnimatedFractionallySizedBox extends StatelessWidget {
  final double heightFactor;
  final Duration duration;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.heightFactor,
    required this.duration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: child,
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
