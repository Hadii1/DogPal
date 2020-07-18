import 'dart:async';
import 'dart:io';
import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/services.dart';

class DecisionsBloc implements BlocBase {
  DecisionsBloc(this._localStorage);

  LocalDataRepositroy _localStorage;
  LocationUtil _locationUtil = LocationUtil();

  StreamController<DecisionState> _stateCtrl = StreamController.broadcast();
  Stream<DecisionState> get state => _stateCtrl.stream;

  StreamController<bool> _navigationCtrl = StreamController.broadcast();
  Stream<bool> get shouldNavigate => _navigationCtrl.stream;

  bool _fetchingLoc = false;

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
          bool isServiceEnabled = await _locationUtil
              .isLocationServiceEnabled()
              .timeout(Duration(seconds: 6), onTimeout: () => false);

          bool isPermissionGranted = await _locationUtil
              .isLocationPermissionGranted()
              .timeout(Duration(seconds: 4), onTimeout: () => false);

          if (isPermissionGranted && isServiceEnabled) {
            await _accessLocation();
          }
          _navigationCtrl.sink.add(true);
        }
      }
    } on SocketException {
      _navigationCtrl.sink.add(true);
    } on PlatformException catch (e, s) {
      _navigationCtrl.sink.add(true);
      sentry.captureException(
        exception: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _askPermission() async {
    _stateCtrl.sink.add(DecisionState.askingPermission);
    _localStorage.setFirstLaunch(false);
  }

  Future<void> onPermissionGranted() async {
    try {
      await _accessLocation();
      _navigationCtrl.sink.add(true);
    } on PlatformException catch (e, s) {
      _navigationCtrl.sink.add(true);
      sentry.captureException(
        exception: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _accessLocation() async {
    if (!_fetchingLoc) {
      _fetchingLoc = true;

      _stateCtrl.sink.add(DecisionState.fetchingLocation);

      LocationData locationData =
          await _locationUtil.getInfoFromPosition().timeout(
                Duration(seconds: 10),
                onTimeout: () => null,
              );

      //Save as default value for adding or querying posts

      if (locationData != null) {
        _localStorage.setUserLocationData(locationData);
      }

      _fetchingLoc = false;
    }
  }
}
