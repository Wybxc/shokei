import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../services/resource_preloader.dart';

/// Loading screen that displays resource preloading progress
class LoadingScreen extends HookWidget {
  final ResourcePreloader preloader;
  final VoidCallback onComplete;

  const LoadingScreen({
    super.key,
    required this.preloader,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStarted = useState(false);

    useEffect(() {
      // Start preloading when screen mounts
      if (!hasStarted.value) {
        hasStarted.value = true;
        // Use addPostFrameCallback to ensure we're not in initState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          preloader.preloadAll(context).then((_) => onComplete());
        });
      }
      return null;
    }, []);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App title
            const Text(
              '処刑',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 200,
              child: AnimatedBuilder(
                animation: preloader,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: preloader.progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Loading text
                      Text(
                        preloader.isLoading
                            ? 'Loading... ${(preloader.progress * 100).toInt()}%'
                            : 'Ready',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),

                      // Current file being loaded
                      if (preloader.currentFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              Text(
                                preloader.currentType,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              Text(
                                preloader.currentFile!.split('/').last,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
