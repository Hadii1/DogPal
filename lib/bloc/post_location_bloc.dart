import 'dart:async';
import 'dart:io';
import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';

class PostLocationBloc implements BlocBase {
  PostLocationBloc(this._localStorage) {
    _city = _localStorage.getPostLocationData().city;
    _town = _localStorage.getPostLocationData().town;
    _district = _localStorage.getPostLocationData().district;
    _locationDisplay = _localStorage.getPostLocationData().display;
  }

  String _city;
  String _town;
  String _district;
  String _locationDisplay;

  final LocalDataRepositroy _localStorage;
  final LocationUtil _locationUtil = LocationUtil();

  StreamController<bool> _shouldLoadCtrl = StreamController.broadcast();
  Stream<bool> get shouldLoad => _shouldLoadCtrl.stream;

  StreamController<String> _errorCtrl = StreamController();
  Stream<String> get errorStream => _errorCtrl.stream;

  StreamController<String> _displayCtrl = StreamController();
  Stream<String> get display => _displayCtrl.stream;

  StreamController<String> _verificationCtrl = StreamController();
  Stream<String> get verifiedPlace => _verificationCtrl.stream;

  StreamController<bool> _isFetchingLocationSuggestions = StreamController();
  Stream<bool> get isFetchingLocationSuggestions =>
      _isFetchingLocationSuggestions.stream;

  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _shouldLoadCtrl.close();
    _errorCtrl.close();
    _isFetchingLocationSuggestions.close();
    _displayCtrl.close();
    _verificationCtrl.close();
  }

  Future<List<Prediction>> onLocationSearch(String input) async {
    _isFetchingLocationSuggestions.sink.add(true);
    var predictions = await _locationUtil.completePlacesQuery(input);
    _isFetchingLocationSuggestions.sink.add(false);
    return predictions;
  }

  void onSuggesstionSelected(Prediction prediction) async {
    try {
      LocationData info =
          await _locationUtil.getDetailsFromPrediction(prediction);

      if (info == null) {
        _errorCtrl.sink.add('Something went wrong on our side');
        return;
      }

      _town = info.town;
      _city = info.city;
      _district = info.district;
      _locationDisplay = prediction.description;

      _displayCtrl.sink.add(prediction.description);
    } on SocketException {
      _errorCtrl.sink.add('Poor Internet Connection');
    } on PlatformException {
      _errorCtrl.sink.add('Something went wrong on our side');
    }
  }

  Future<void> onCurrentLocationPressed() async {
    if (!_isFetchingLocation) {
      _isFetchingLocation = true;
      _shouldLoadCtrl.sink.add(true);
      try {
        if (await isOnline()) {
          bool isServiceEnabled = await LocationUtil()
              .isLocationServiceEnabled()
              .timeout(Duration(seconds: 5), onTimeout: () => null);

          if (isServiceEnabled == null) {
            _errorCtrl.sink.add(
                'Fetching location took more than expected. Please try again');
            _isFetchingLocation = false;
            _shouldLoadCtrl.sink.add(false);
            return;
          }

          if (!isServiceEnabled) {
            _errorCtrl.sink.add(GeneralConstants.LOCATION_SERVICE_OFF_MSG);
            _isFetchingLocation = false;
            _shouldLoadCtrl.sink.add(false);
            return;
          }

          bool permissionGranted = await checkAndAskPermission(
                  permission: Permission.locationWhenInUse)
              .timeout(Duration(seconds: 5), onTimeout: () => null);

          if (permissionGranted == null) {
            _errorCtrl.sink.add(
                'Fetching location took more than expected. Please try again');
            _isFetchingLocation = false;
            _shouldLoadCtrl.sink.add(false);
            return;
          }

          if (!permissionGranted) {
            _errorCtrl.sink.add('Access to location was denied');
            _isFetchingLocation = false;
            _shouldLoadCtrl.sink.add(false);
            return;
          }

          LocationUtil locationUtil = LocationUtil();

          LocationData data = await locationUtil
              .getInfoFromPosition()
              .timeout(Duration(seconds: 12), onTimeout: () => null);

          if (data == null) {
            _errorCtrl.sink.add('An error occured on our side. Try again.');
          } else {
            _town = data.town;
            _city = data.city;
            _district = data.district;
            _locationDisplay = data.display;

            _displayCtrl.sink.add(_locationDisplay);
          }
        } else {
          _errorCtrl.sink
              .add('Your\'re offline. Please check your internet connection');
        }
      } on SocketException {
        _errorCtrl.sink.add('Poor Internet Connection');
      } on PlatformException catch (e, s) {
        _errorCtrl.sink.add('An error occured on our side. Try again.');
        sentry.captureException(exception: e, stackTrace: s);
      }
      _isFetchingLocation = false;
    }

    _shouldLoadCtrl.sink.add(false);
  }

  void onVerifyPressed() {
    _verificationCtrl.sink.add(_locationDisplay);
    _localStorage.setPostLocationData(
      LocationData(
        city: _city,
        district: _district,
        town: _town,
        display: _locationDisplay,
      ),
    );
  }
}
