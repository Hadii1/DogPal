import 'dart:async';
import 'dart:io';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class DogPostsBloc implements BlocBase {
  DogPostsBloc(this._localStorage) {
    town = _localStorage.getLocationData()[UserConsts.TOWN];
    city = _localStorage.getLocationData()[UserConsts.CITY];
    district = _localStorage.getLocationData()[UserConsts.DISTRICT];

    pageController.addListener(
      () {
        if (isHalfScrolled()) {
          loadMorePosts();
        }
      },
    );

    activeFilters.listen((int i) {
      filters = i;
    });
  }
  final LocalStorage _localStorage;

  final PageController pageController = PageController();
  final TextEditingController cityNameController = TextEditingController();

  StreamController<String> _locationCtrl = StreamController.broadcast();
  Stream<String> get locationChanges => _locationCtrl.stream;

  //When a suggestion is pressed we want to show the fab and filter buttons
  //so we hook this stream to the animated header widget and re-render it
  //when a suggestion is pressed
  StreamController<bool> _didPressSuggestion = StreamController.broadcast();
  Stream<bool> get isSuggestionPressed => _didPressSuggestion.stream;

  Stream<int> get activeFilters;
  Stream<DataState> get dataState;

  int filters = 0;

  StreamController<DataState> stateCtrl;

  List<DogPost> posts;

  bool _fetchingLocation = false;

  String town;
  String district;
  String city;

  bool isHalfScrolled() {
    double maxScroll = pageController.position.maxScrollExtent;
    double currentScroll = pageController.position.pixels;
    return maxScroll - currentScroll <= maxScroll * 0.4;
  }

  @override
  void dispose() {
    stateCtrl.close();
    _didPressSuggestion.close();
    _locationCtrl.close();
  }

  void onSuggestionSelected() {
    _didPressSuggestion.sink.add(true);
  }

  void clearFilters();

  void recountFilters();

  Future<void> getPosts();

  void loadMorePosts();

  Future<void> nearByPressed() async {
    if (!_fetchingLocation) {
      _fetchingLocation = true;

      cityNameController.clear();

      stateCtrl.sink.add(DataState.loading);

      try {
        if (await isOnline()) {
          bool permissionGranted = await checkAndAskPermission(
              permission: Permission.locationWhenInUse);
          if (permissionGranted) {
            Map<String, String> locationData =
                await LocationUtil().getInfoFromPosition().timeout(
                      Duration(seconds: 14),
                      onTimeout: () => null,
                    );

            if (locationData == null) {
              stateCtrl.sink.add(DataState.locationUnknownError);
            } else {
              town = locationData[UserConsts.TOWN];
              city = locationData[UserConsts.CITY];
              district = locationData[UserConsts.DISTRICT];
              _localStorage.saveUserLocationData(locationData);

              _locationCtrl.sink.add(town ?? city ?? district);

              await getPosts();
            }
          } else {
            stateCtrl.sink.add(DataState.locationDenied);
          }
        } else {
          stateCtrl.sink.add(DataState.locationNetworkError);
        }
      } on SocketException {
        stateCtrl.sink.add(DataState.locationNetworkError);
      } on PlatformException catch (e, s) {
        print(e.message ?? e.code);
        stateCtrl.sink.add(DataState.locationUnknownError);
        sentry.captureException(
          exception: e,
          stackTrace: s,
        );
      }
      _fetchingLocation = false;
    }
  }
}
