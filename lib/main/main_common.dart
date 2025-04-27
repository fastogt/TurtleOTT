import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:turtleott/app_config.dart';
import 'package:turtleott/base/websocket/online_subscribers_bloc/online_subscribers_bloc.dart';
import 'package:turtleott/base/websocket/websocket_api_bloc/websocket_api_bloc.dart';
import 'package:turtleott/pages/mobile_app_root.dart';
import 'package:turtleott/pages/tv_app_root.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/utils/theme.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> mainCommon() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  await setupLocator();
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WebSocketApiBloc>(create: (_) => WebSocketApiBloc()),
        ProxyProvider<WebSocketApiBloc, RealtimeMessageBloc>(update: (_, ws, __) {
          return RealtimeMessageBloc(ws);
        }, dispose: (_, bloc) {
          return bloc.dispose();
        }),
      ],
      child: FractionallySizedBox(
        heightFactor: 1,
        widthFactor: 1,
        child: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.undo): const ActivateIntent(),
          },
          child: AppLocalizations(
            init: AppConfig.of(context).isDev ? const Locale('en', 'US') : const Locale('sr', 'SR'),
            locales: {const Locale('en', 'US'): 'English', const Locale('sr', 'SR'): 'Serbia'},
            child: Builder(
              builder: (context) {
                return MaterialApp(
                  theme: Theming.of(context).theme,
                  debugShowCheckedModeBanner: false,
                  supportedLocales: AppLocalizations.of(context)!.supportedLocales,
                  // These delegates make sure that the localization data for the proper language is loaded
                  localizationsDelegates: [
                    AppLocalizations.of(context)!.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate
                  ],
                  locale: AppLocalizations.of(context)!.currentLocale,
                  localeResolutionCallback: (locale, supportedLocales) {
                    for (final supportedLocale in supportedLocales) {
                      if (locale != null) {
                        if (supportedLocale.languageCode == locale.languageCode &&
                            supportedLocale.countryCode == locale.countryCode) {
                          return supportedLocale;
                        }
                      }
                    }
                    return supportedLocales.first;
                  },
                  home: ScaffoldMessenger(child: _root()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _root() {
    final device = locator<RuntimeDevice>();
    return device.hasTouch ? const MobileAppRoot() : const TVAppRoot();
  }
}
