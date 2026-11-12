import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/locale/locale_controller.dart';
import 'package:qaari_sl_mobile/core/theme/app_palette.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/core/theme/theme_mode_controller.dart';
import 'package:qaari_sl_mobile/features/splash/splash_screen.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';

class QaariSlApp extends ConsumerWidget {
  const QaariSlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      builder: (context, child) {
        final top = MediaQuery.paddingOf(context).top;
        final palette = context.palette;
        final dark = palette.brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: palette.bg,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: ColoredBox(
            color: palette.bg,
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        _FallbackMaterialLocalizationsDelegate(),
        _FallbackCupertinoLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppConstants.supportedLocales,
      home: const SplashScreen(),
    );
  }
}

/// Somali is an app language but not a Flutter Material locale — fall back to EN.
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppConstants.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final materialLocale = locale.languageCode == 'ar'
        ? const Locale('ar')
        : const Locale('en');
    return GlobalMaterialLocalizations.delegate.load(materialLocale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MaterialLocalizations> old,
  ) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppConstants.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final cupertinoLocale = locale.languageCode == 'ar'
        ? const Locale('ar')
        : const Locale('en');
    return GlobalCupertinoLocalizations.delegate.load(cupertinoLocale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<CupertinoLocalizations> old,
  ) => false;
}
