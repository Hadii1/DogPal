import 'dart:async';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/utils/decision_util.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  // Whenever an error occurs, call the `_reportError` function. This sends
  // Dart errors to the dev console or Sentry depending on the environment.
  runZoned(() async {
    runApp(MyApp());
  }, onError: (e, s) {
    reportError(e, s);
  });

  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => AppBloc(),
        ),
        Provider(
          create: (_) => LocalStorage(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            modalBackgroundColor: Color(0xfffffffa),
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            backgroundColor: Color(0xfffffffa),
          ),
          splashColor: Colors.orangeAccent,
          backgroundColor: yellowishColor,
          scaffoldBackgroundColor: yellowishColor,
          tabBarTheme: TabBarTheme(
            labelColor: blackishColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(color: blackishColor, fontFamily: 'OpenSans'),
            unselectedLabelStyle:
                TextStyle(color: blackishColor, fontFamily: 'OpenSans'),
          ),
          appBarTheme: AppBarTheme(
            color: yellowishColor,
            brightness: Brightness.light,
            elevation: 0.8,
            iconTheme: IconThemeData(color: blackishColor),
            textTheme: TextTheme(
              headline6: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontFamily: 'OpenSans',
                letterSpacing: 0.5,
              ),
            ),
          ),
          brightness: Brightness.light,
          snackBarTheme: SnackBarThemeData(
            shape: Border(
              top: BorderSide(color: blackishColor, width: 0.3),
            ),
            actionTextColor: Color(0xff004d51),
            contentTextStyle: TextStyle(
              color: blackishColor,
              fontFamily: 'OpenSans',
              fontSize: 14,
            ),
            backgroundColor: yellowishColor,
          ),
          buttonTheme: ButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            buttonColor: Color(0xff007A7D),
            textTheme: ButtonTextTheme.primary,
            splashColor: Color(0xffD7A339),
            highlightColor: Color(0xffD7A339),
          ),
          primaryColor: Color(0xff007A7D),
          primaryColorDark: Color(0xff004d51),
          primaryColorLight: Color(0xff4ba9ac),
          accentColor: Color(0xffD7A339),
          fontFamily: 'Comfortaa',
          inputDecorationTheme: InputDecorationTheme(
            border: UnderlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: blackishColor),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: blackishColor),
            ),
            labelStyle: TextStyle(color: blackishColor),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
