import 'dart:async';
import 'dart:io';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DecisionState {
  unAuthenticated,
  askingPermission,
  fetchingLocation,
}

class DecisionsBloc implements BlocBase {
  DecisionsBloc(this._localStorage);

  LocalStorage _localStorage;
  LocationUtil _locationUtil = LocationUtil();

  StreamController<DecisionState> _stateCtrl = StreamController.broadcast();
  Stream<DecisionState> get state => _stateCtrl.stream;

  StreamController<bool> _navigationCtrl = StreamController.broadcast();
  Stream<bool> get shouldNavigate => _navigationCtrl.stream;

  bool _fetchingLoc = false;

  SnackBar locationNotification;

  @override
  void dispose() {
    _stateCtrl.close();
    _navigationCtrl.close();
  }

  void skipPressed() {
    _navigationCtrl.sink.add(true);
  }

  void setFirstState() {
    if (_localStorage.isAuthenticated()) {
      checkLocationPermission();
    } else {
      _stateCtrl.sink.add(DecisionState.unAuthenticated);
    }
  }

  void checkLocationPermission() async {
    try {
      if (await isOnline()) {
        if (_localStorage.isFirstLaunch()) {
          _askPermission();
        } else {
          bool isPermissionGranted = await _locationUtil
              .isLocationPermissionGranted()
              .timeout(Duration(seconds: 4), onTimeout: () => false);

          if (isPermissionGranted) {
            accessLocation();
          } else {
            _navigationCtrl.sink.add(true);
          }
        }
      } else {
        locationNotification = noConnectionSnackbar();
        _navigationCtrl.sink.add(true);
      }
    } on SocketException {
      locationNotification = errorSnackBar('Poor Internet Connection.');
      _navigationCtrl.sink.add(true);
    } on PlatformException {
      locationNotification =
          errorSnackBar('Something went wrong while retrieving location.');
      _navigationCtrl.sink.add(true);
    }
  }

  Future<void> _askPermission() async {
    _stateCtrl.sink.add(DecisionState.askingPermission);
    _localStorage.setFirstLaunch(false);
  }

  Future<void> accessLocation() async {
    if (!_fetchingLoc) {
      _fetchingLoc = true;

      _stateCtrl.sink.add(DecisionState.fetchingLocation);

      try {
        Map<String, String> locationData =
            await _locationUtil.getInfoFromPosition().timeout(
          Duration(seconds: 10),
          onTimeout: () {
            return null;
          },
        );

        if (locationData != null) {
          _localStorage.saveUserLocationData(locationData);

          locationNotification = SnackBar(
            content: Text(
              'Showing results in ${locationData[UserConsts.TOWN] ?? locationData[UserConsts.CITY] ?? locationData[UserConsts.DISTRICT]}',
            ),
          );
        } else {
          locationNotification =
              errorSnackBar('An error occured while retrieving location');
        }
      } on SocketException {
        locationNotification = errorSnackBar(
            'Couldn\'t retrieve location. Poor Internet Connection.');
      } on PlatformException catch (e, s) {
        sentry.captureException(
          exception: e,
          stackTrace: s,
        );
        String error;

        if (e.code == 'PERMISSION_DENIED') {
          error = 'Couldn\'t retrieve location. Access was denied';
        } else {
          error = 'Something went wrong while retrieving location';
        }

        locationNotification = errorSnackBar(error);
      }

      _fetchingLoc = false;
      _navigationCtrl.sink.add(true);
    }
  }
}