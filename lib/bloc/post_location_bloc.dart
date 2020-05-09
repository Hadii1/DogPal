import 'dart:async';
import 'dart:io';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PostLocationBloc implements BlocBase {
  PostLocationBloc(this._localStorage) {
    _city = _localStorage.getPostLocationData()[UserConsts.CITY];
    _town = _localStorage.getPostLocationData()[UserConsts.TOWN];
    _district = _localStorage.getPostLocationData()[UserConsts.DISTRICT];
    _display =
        _localStorage.getPostLocationData()[UserConsts.LOCATION_DISPLAY];
  }

  String _city;
  String _town;
  String _district;
  String _display;

  final LocalStorage _localStorage;

  StreamController<bool> _shouldLoadCtrl = StreamController.broadcast();
  Stream<bool> get shouldLoad => _shouldLoadCtrl.stream;

  StreamController<String> _errorCtrl = StreamController();
  Stream<String> get errorStream => _errorCtrl.stream;

  StreamController<String> _cityNameCtrl = StreamController();
  Stream<String> get cityName => _cityNameCtrl.stream;

  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _shouldLoadCtrl.close();
    _errorCtrl.close();
    _cityNameCtrl.close();
  }

  void searchBarLocationSelected(
      String town, String city, String district, String display) {
    _cityNameCtrl.sink.add(display);

    _city = city;
    _town = town;
    _district = district;
    _display = display;
  }

  Future<void> currentLocationPressed() async {
    if (!_isFetchingLocation) {
      _isFetchingLocation = true;
      _shouldLoadCtrl.sink.add(true);
      try {
        if (await isOnline()) {
          bool permissionGranted = await checkAndAskPermission(
              permission: Permission.locationWhenInUse);

          if (permissionGranted) {
            LocationUtil locationUtil = LocationUtil();

            Map<String, String> info = await locationUtil
                .getInfoFromPosition()
                .timeout(Duration(seconds: 12), onTimeout: () => null);

            if (info == null) {
              _errorCtrl.sink.add('An error occured on our side. Try again.');
            } else {
              _town = info[UserConsts.TOWN];
              _city = info[UserConsts.CITY];
              _district = info[UserConsts.DISTRICT];
              _display = info[UserConsts.LOCATION_DISPLAY];

              _cityNameCtrl.sink.add(_display ?? _town ?? _city ?? _district);
            }
          } else {
            _errorCtrl.sink.add(GeneralConstants.LOCATION_PERMISSION_ERROR);
          }
        } else {
          _errorCtrl.sink
              .add('Your\'re offline. Please check your internet conncetoin');
        }
      } on SocketException {
        _errorCtrl.sink.add('Poor Internet Connection');
      } on PlatformException {
        _errorCtrl.sink.add('An error occured on our side. Try again.');
      }
      _isFetchingLocation = false;
    }

    _shouldLoadCtrl.sink.add(false);
  }

  void savePostLocation() {
    _localStorage.savePostLocationData({
      UserConsts.TOWN: _town,
      UserConsts.CITY: _city,
      UserConsts.DISTRICT: _district,
      UserConsts.LOCATION_DISPLAY: _display,
    });
  }
}
