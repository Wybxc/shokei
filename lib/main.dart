import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ShokeiApp());
}

class ShokeiApp extends StatelessWidget {
  const ShokeiApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: const HomeScreen(),
        );
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}
