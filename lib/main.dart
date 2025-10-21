import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'services/resource_preloader.dart';
import 'providers/audio_preloader_provider.dart';
import 'generated/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ShokeiApp());
}

class ShokeiApp extends HookWidget {
  const ShokeiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create and manage resource preloader
    final preloader = useMemoized(() => ResourcePreloader());
    final isLoaded = useState(false);

    // Dispose preloader when widget is disposed
    useEffect(() {
      return preloader.dispose;
    }, [preloader]);

    // Handle loading completion
    void onLoadingComplete() {
      isLoaded.value = true;
    }

    return MaterialApp(
      title: '処刑',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B0029),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            bottomSheetTheme: theme.bottomSheetTheme.copyWith(
              backgroundColor: theme.colorScheme.primary,
              dragHandleColor: theme.colorScheme.primaryContainer,
            ),
          ),
          child: isLoaded.value
              ? ResourcePreloaderProvider(
                  preloader: preloader,
                  child: const HomeScreen(),
                )
              : LoadingScreen(
                  preloader: preloader,
                  onComplete: onLoadingComplete,
                ),
        );
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}
