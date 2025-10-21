import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../generated/app_localizations.dart';

/// Common bottom sheet wrapper that provides consistent styling
class _BottomSheetWrapper extends StatelessWidget {
  final Widget child;

  const _BottomSheetWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    );
  }
}

/// About bottom sheet - shown on tap
class AboutBottomSheet extends StatelessWidget {
  const AboutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      child: _AboutContent(),
    );
  }
}

/// Debug info bottom sheet - shown on long press
class DebugInfoBottomSheet extends StatelessWidget {
  const DebugInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      child: _DebugInfoContent(),
    );
  }
}

/// About content with app information and social links
class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const whiteText = TextStyle(color: Colors.white);
    const whiteTextBold =
        TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Image.asset('assets/images/logo.png', height: 100),
        const SizedBox(height: 16),

        // Title
        Text(
          l10n.aboutTitle,
          style: whiteTextBold.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          l10n.aboutDescription,
          style: whiteText.copyWith(fontSize: 10, height: 1.6),
          textAlign: TextAlign.center,
        ),
        if (l10n.aboutDescription != l10n.aboutDescriptionJa)
          const SizedBox(height: 8),
        if (l10n.aboutDescription != l10n.aboutDescriptionJa)
          Text(
            l10n.aboutDescriptionJa,
            style: whiteText.copyWith(fontSize: 10, height: 1.6),
            textAlign: TextAlign.center,
          ),

        // Divider
        const Divider(color: Colors.white30, height: 32),

        // App info
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final version = snapshot.hasData ? snapshot.data!.version : '...';
            return Text(
              '${l10n.appName}\n${l10n.versionLabel} $version\n${l10n.developerInfo}',
              style: whiteText.copyWith(
                  fontSize: 9, height: 1.5, color: Colors.white70),
              textAlign: TextAlign.center,
            );
          },
        ),
        const SizedBox(height: 16),

        // Social links
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 10, color: Colors.white30),
            children: [
              TextSpan(
                text: l10n.githubLabel,
                recognizer: TapGestureRecognizer()
                  ..onTap =
                      () => launchUrl(Uri.parse('https://github.com/Wybxc')),
              ),
              const TextSpan(text: '  ｜  '),
              TextSpan(
                text: l10n.bilibiliLabel,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchUrl(
                        Uri.parse('https://space.bilibili.com/85438718'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Debug info content with system information
class _DebugInfoContent extends HookWidget {
  const _DebugInfoContent();

  @override
  Widget build(BuildContext context) {
    const whiteText = TextStyle(color: Colors.white);

    return FutureBuilder<Map<String, String>>(
      future: _getDebugInfo(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white30,
                ),
              ),
            ),
          );
        }

        final debugInfo = snapshot.data!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Debug Info',
              style: whiteText.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Debug info items
            for (var entry in debugInfo.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${entry.key}:',
                        style: whiteText.copyWith(
                          fontSize: 10,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value,
                        style: whiteText.copyWith(
                          fontSize: 10,
                          height: 1.5,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>> _getDebugInfo(BuildContext context) async {
    final Map<String, String> info = {};

    // Get all data from context BEFORE any async operations
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    final orientation = mediaQuery.orientation;
    final brightness = mediaQuery.platformBrightness;
    final textScaler = mediaQuery.textScaler;
    final accessibleNavigation = mediaQuery.accessibleNavigation;
    final boldText = mediaQuery.boldText;
    final highContrast = mediaQuery.highContrast;
    final locale = Localizations.maybeLocaleOf(context);

    // Flutter & Dart version info
    info['Flutter Mode'] = kDebugMode
        ? 'Debug'
        : kProfileMode
            ? 'Profile'
            : 'Release';

    // Platform
    info['Platform'] = defaultTargetPlatform.name;

    // Get device info
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        info['Browser'] = webInfo.browserName.name;
        info['User Agent'] = webInfo.userAgent ?? 'Unknown';
        if (webInfo.vendor != null && webInfo.vendor!.isNotEmpty) {
          info['Vendor'] = webInfo.vendor!;
        }
        info['Language'] = webInfo.language ?? 'Unknown';
        info['Platform Type'] = webInfo.platform ?? 'Unknown';
        info['WASM'] = kIsWasm ? 'Yes' : 'No';
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final androidInfo = await deviceInfo.androidInfo;
            info['Device'] = '${androidInfo.manufacturer} ${androidInfo.model}';
            info['Android Version'] = 'API ${androidInfo.version.sdkInt}';
            info['Brand'] = androidInfo.brand;
            if (androidInfo.isPhysicalDevice) {
              info['Type'] = 'Physical Device';
            } else {
              info['Type'] = 'Emulator';
            }
            break;
          case TargetPlatform.iOS:
            final iosInfo = await deviceInfo.iosInfo;
            info['Device'] = iosInfo.name;
            info['iOS Version'] = iosInfo.systemVersion;
            info['Model'] = iosInfo.model;
            info['Type'] =
                iosInfo.isPhysicalDevice ? 'Physical Device' : 'Simulator';
            break;
          case TargetPlatform.macOS:
            final macInfo = await deviceInfo.macOsInfo;
            info['Device'] = macInfo.computerName;
            info['Model'] = macInfo.model;
            info['OS Version'] = macInfo.osRelease;
            break;
          case TargetPlatform.windows:
            final windowsInfo = await deviceInfo.windowsInfo;
            info['Computer Name'] = windowsInfo.computerName;
            info['OS Version'] = windowsInfo.displayVersion;
            break;
          case TargetPlatform.linux:
            final linuxInfo = await deviceInfo.linuxInfo;
            info['Device'] = linuxInfo.name;
            info['Version'] = linuxInfo.version ?? 'Unknown';
            break;
          default:
            break;
        }
      }
    } catch (e) {
      info['Device Info'] = 'Error: ${e.toString().substring(0, 30)}...';
    }

    // Screen info
    info['Screen Size'] = '${size.width.toInt()}×${size.height.toInt()}px';
    info['Logical Size'] =
        '${size.width.toStringAsFixed(1)}×${size.height.toStringAsFixed(1)}';
    info['Pixel Ratio'] = devicePixelRatio.toStringAsFixed(2);
    info['Physical Size'] =
        '${(size.width * devicePixelRatio).toInt()}×${(size.height * devicePixelRatio).toInt()}px';
    info['Orientation'] =
        orientation == Orientation.portrait ? 'Portrait' : 'Landscape';
    info['Brightness'] = brightness == Brightness.light ? 'Light' : 'Dark';

    // Safe area
    info['Safe Area Top'] = '${padding.top.toInt()}px';
    info['Safe Area Bottom'] = '${padding.bottom.toInt()}px';
    info['Safe Area Left'] = '${padding.left.toInt()}px';
    info['Safe Area Right'] = '${padding.right.toInt()}px';

    // Viewport insets (keyboard, etc.)
    if (viewInsets.bottom > 0) {
      info['Keyboard Height'] = '${viewInsets.bottom.toInt()}px';
    }

    // Text scale factor
    final scaleFactor = textScaler.scale(1.0);
    if (scaleFactor != 1.0) {
      info['Text Scale'] = scaleFactor.toStringAsFixed(2);
    }

    // Vibration support
    try {
      final hasVibrator = await Vibration.hasVibrator();
      final hasAmplitudeControl = await Vibration.hasAmplitudeControl();
      final hasCustomVibrationsSupport =
          await Vibration.hasCustomVibrationsSupport();

      info['Vibration'] = hasVibrator == true ? 'Supported' : 'Not supported';
      if (hasVibrator == true) {
        info['Vibration Amplitude'] =
            hasAmplitudeControl == true ? 'Yes' : 'No';
        info['Custom Vibrations'] =
            hasCustomVibrationsSupport == true ? 'Yes' : 'No';
      }
    } catch (e) {
      info['Vibration'] = 'Not available';
    }

    // Locale info
    if (locale != null) {
      var localeString = locale.languageCode;
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        localeString += '_${locale.countryCode}';
      }
      info['Locale'] = localeString;
    }

    // Accessibility
    if (accessibleNavigation) {
      info['Accessible Nav'] = 'Enabled';
    }
    if (boldText) {
      info['Bold Text'] = 'Enabled';
    }
    if (highContrast) {
      info['High Contrast'] = 'Enabled';
    }

    return info;
  }
}
