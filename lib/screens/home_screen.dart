import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../widgets/execution_button.dart';
import '../widgets/info_bottom_sheet.dart';
import '../generated/app_localizations.dart';

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

    void showAboutInfo() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => const AboutBottomSheet(),
      );
    }

    void showDebugInfo() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => const DebugInfoBottomSheet(),
      );
    }

    return Stack(children: [
      // Background image
      Positioned.fill(
        child: Image.asset(
          'assets/images/background.jpg',
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
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
                    onTap: showAboutInfo,
                    onLongPress: showDebugInfo,
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
      )
    ]);
  }
}
