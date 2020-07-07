import 'dart:async';
import 'package:dog_pal/navigators/app_navigator.dart';
import 'package:dog_pal/screens/splash_screen.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  // Whenever an error occurs, call the `_reportError` function. This sends
  // Dart errors to the dev console or Sentry depending on the environment.
  runZoned(
    () async {
      runApp(MyApp());
    },
    onError: (e, s) {
      reportError(e, s);
    },
  );

  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _setStatusBarColor();
    return Provider<LocalStorage>(
      create: (_) => LocalStorage(),
      child: MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        theme: appTheme,
        home: SplashScreen(),
      ),
    );
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
