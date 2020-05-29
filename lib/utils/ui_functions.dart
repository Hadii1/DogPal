import 'dart:io';
import 'dart:math';
import 'package:android_intent/android_intent.dart';
import 'package:dog_pal/bloc/auth_bloc.dart';
import 'package:dog_pal/screens/login.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

SnackBar permissionSnackbar(
  String text, {
  @required Permission androidPermission,
}) {
  return SnackBar(
    duration: Duration(seconds: 5),
    content: Row(
      children: <Widget>[
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: blackishColor,
              fontFamily: 'OpenSans',
              fontSize: 14,
            ),
          ),
        )
      ],
    ),
    action: SnackBarAction(
      label: 'Enable',
      onPressed: () async => Platform.isIOS
          ? await openAppSettings()
          : await androidPermission.shouldShowRequestRationale
              ? await [androidPermission].request()
              : await openAppSettings(),
    ),
  );
}

SnackBar locationServiceSnackbar() {
  return SnackBar(
    duration: Duration(seconds: 4),
    content: Row(
      children: <Widget>[
        Expanded(
          child: Text(
            GeneralConstants.LOCATION_SERVICE_OFF_MSG,
            style: TextStyle(
              color: blackishColor,
              fontFamily: 'OpenSans',
              fontSize: 14,
            ),
          ),
        )
      ],
    ),
    action: SnackBarAction(
      label: 'Enable',
      onPressed: () async {
        if (Platform.isIOS) {
          await openAppSettings();
        } else {
          final AndroidIntent intent = new AndroidIntent(
            action: 'android.settings.LOCATION_SOURCE_SETTINGS',
          );
          await intent.launch();
        }
      },
    ),
  );
}

SnackBar noConnectionSnackbar() {
  return SnackBar(
    duration: Duration(seconds: 4),
    content: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
          child: Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xffC24444),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'No Internet Connection',
          ),
        ),
      ],
    ),
  );
}

SnackBar errorSnackBar(
  String text, {
  Duration duration,
  Function onRetry,
}) {
  return SnackBar(
    duration: duration ?? Duration(seconds: 3),
    content: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Color(0xffC24444),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            softWrap: true,
          ),
        ),
      ],
    ),
    action: onRetry != null
        ? SnackBarAction(
            label: 'Retry',
            textColor: Color(0xff007A7D),
            onPressed: onRetry,
          )
        : null,
  );
}

SnackBar signInSnackBar(BuildContext context, {String text}) {
  return SnackBar(
    duration: Duration(seconds: 3),
    action: SnackBarAction(
      label: 'Sign In',
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) {
              return Provider(
                create: (_) =>
                    AuthBloc(Provider.of<LocalStorage>(context, listen: false)),
                child: LoginScreen(),
              );
            },
          ),
        );
      },
    ),
    content: Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Text(
            text ?? 'Please Sign in to add a post',
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}

String getRandomDogImage() {
  List<String> images = [
    'assets/cute_dog.png',
    'assets/cute_dog_2.png',
    'assets/cute_dog_3.png'
  ];

  int r = Random().nextInt(3);
  return images[r];
}
