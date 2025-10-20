import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/execution_button.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final infoButtonOpacity = useState(1.0);

    // Show tip on mount
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.tipFromEma),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: l10n.snackbarActionLabel,
                onPressed: () {
                  // Dismiss snackbar
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      });
      return null;
    }, []);

    void onPressStart() {
      infoButtonOpacity.value = 0.0;
    }

    void onPressEnd() {
      infoButtonOpacity.value = 1.0;
    }

    void showAboutBottomSheet() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _buildBottomSheet(context),
      );
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
            child: AnimatedOpacity(
              opacity: infoButtonOpacity.value,
              duration: infoButtonOpacity.value == 0.0
                  ? const Duration(milliseconds: 100)
                  : const Duration(milliseconds: 200),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: showAboutBottomSheet,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.info_outline,
                      // color: Color(0xFF252525),
                      size: 32,
                    ),
                  ),
                ),
              ),
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
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF4B0029),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Logo
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.aboutTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                '${l10n.aboutDescriptionZh}\n\n${l10n.aboutDescriptionJa}',
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.6,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              // Divider
              const Divider(
                color: Colors.white30,
                height: 32,
              ),

              // App info
              Text(
                '${l10n.appName}\n${l10n.versionLabel} 1.2.0\n${l10n.developerInfo}',
                style: const TextStyle(
                  fontSize: 9,
                  height: 1.5,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Social links
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white30,
                  ),
                  children: [
                    TextSpan(
                      text: l10n.xLabel,
                      style: const TextStyle(
                        color: Color(0xFFFF45AB),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => launchUrl(Uri.parse('https://x.com/wybxc')),
                    ),
                    const TextSpan(text: '  ｜  '),
                    TextSpan(
                        text: l10n.bilibiliLabel,
                        style: const TextStyle(
                          color: Color(0xFFFF45AB),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                                Uri.parse(
                                    'https://space.bilibili.com/327507343'),
                              )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
