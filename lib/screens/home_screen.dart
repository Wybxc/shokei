import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/execution_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _showBottomSheet = false;
  late AnimationController _aboutAlphaController;
  late Animation<double> _aboutAlphaAnimation;

  @override
  void initState() {
    super.initState();
    _aboutAlphaController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _aboutAlphaAnimation =
        Tween<double>(begin: 1.0, end: 1.0).animate(_aboutAlphaController);
    _checkAndShowTip();
  }

  @override
  void dispose() {
    _aboutAlphaController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowTip() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('tip_shown') ?? false;
    if (!shown && mounted) {
      await prefs.setBool('tip_shown', true);
      if (mounted) {
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
      }
    }
  }

  void _onPressStart() {
    _aboutAlphaController.animateTo(0.0,
        duration: const Duration(milliseconds: 100));
  }

  void _onPressEnd() {
    _aboutAlphaController.animateTo(1.0,
        duration: const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
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
              animation: _aboutAlphaAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _aboutAlphaAnimation.value,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _showBottomSheet = true),
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
              onPressStart: _onPressStart,
              onPressEnd: _onPressEnd,
            ),
          ),

          // Bottom sheet
          if (_showBottomSheet)
            GestureDetector(
              onTap: () => setState(() => _showBottomSheet = false),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          if (_showBottomSheet)
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
              color: Colors.white.withOpacity(0.4),
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
