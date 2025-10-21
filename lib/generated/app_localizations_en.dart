// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => '処刑';

  @override
  String get tipFromEma =>
      'Hint from Ema: Double tap the button to reset the state';

  @override
  String get snackbarActionLabel => 'OK';

  @override
  String get aboutTitle => 'About';

  @override
  String get versionLabel => 'Version:';

  @override
  String get aboutDescriptionJa =>
      '本アプリは、Re,AER 傘下のブランド Acacia によって制作された推理文字アドベンチャーゲーム「魔法少女ノ魔女裁判」の二次創作作品です。';

  @override
  String get aboutDescription =>
      'This app is a derivative work of the reasoning text adventure game \"Mahou Shoujo no Majo Saiban\" (魔法少女ノ魔女裁判) created by Acacia, a brand under Re,AER.';

  @override
  String get developerInfo => 'Developed by Wybxc';

  @override
  String get githubLabel => 'GitHub';

  @override
  String get bilibiliLabel => 'Bilibili';
}
