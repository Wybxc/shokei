import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/execution_button.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showBottomSheet = useState(false);
    final aboutAlphaController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final aboutAlphaAnimation = useMemoized(
      () => Tween<double>(begin: 1.0, end: 1.0).animate(aboutAlphaController),
      [aboutAlphaController],
    );

    // Show tip on mount
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.tipFromEma),
              duration: const Duration(seconds: 4),
              backgroundColor: const Color(0xFF4B0029),
            ),
          );
        }
      });
      return null;
    }, []);

    void onPressStart() {
      aboutAlphaController.animateTo(0.0,
          duration: const Duration(milliseconds: 100));
    }

    void onPressEnd() {
      aboutAlphaController.animateTo(1.0,
          duration: const Duration(milliseconds: 200));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Info button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            child: AnimatedBuilder(
              animation: aboutAlphaAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: aboutAlphaAnimation.value,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showBottomSheet.value = true,
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF252525),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Execution button
          Center(
            child: ExecutionButton(
              size: 240,
              onPressStart: onPressStart,
              onPressEnd: onPressEnd,
            ),
          ),

          // Bottom sheet
          if (showBottomSheet.value)
            GestureDetector(
              onTap: () => showBottomSheet.value = false,
              child: Container(
                color: Colors.black.withAlpha((0.6 * 255).toInt()),
              ),
            ),
          if (showBottomSheet.value)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomSheet(context),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF4B0029),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.4 * 255).toInt()),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.aboutTitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${localizations.aboutDescriptionZh}\n\n'
                  '${localizations.aboutDescriptionJa}\n\n'
                  '${localizations.appName}\n'
                  '${localizations.versionLabel} 1.2.0\n'
                  '${localizations.developerInfo}\n',
                  style: const TextStyle(
                    fontSize: 8,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Launch URL - requires url_launcher package
                      },
                      child: Text(
                        localizations.xLabel,
                        style: const TextStyle(
                          color: Color(0xFFFF45AB),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(
                      '｜',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        // Launch URL - requires url_launcher package
                      },
                      child: Text(
                        localizations.bilibiliLabel,
                        style: const TextStyle(
                          color: Color(0xFFFF45AB),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
