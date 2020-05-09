import 'dart:io';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fade_in_widget.dart';

class LocationAccessDenied extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fader(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(getRandomDogImage()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Access to location was denied'),
                Icon(
                  Icons.error,
                  color: blackishColor,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              if (Platform.isIOS) {
                await openAppSettings();
              } else {
                await Permission.locationWhenInUse.shouldShowRequestRationale
                    ? await [Permission.locationWhenInUse].request()
                    : await openAppSettings();
              }
            },
            child: Text(
              'Allow Location',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      ),
    );
  }
}
