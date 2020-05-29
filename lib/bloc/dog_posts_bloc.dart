import 'dart:async';
import 'dart:io';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class DogPostsBloc implements BlocBase {
  DogPostsBloc(this._localStorage) {
    town = _localStorage.getUserLocationData().userTown;
    city = _localStorage.getUserLocationData().userCity;
    district = _localStorage.getUserLocationData().userDistrict;

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
  final LocalDataRepositroy _localStorage;

  final PageController pageController = PageController();
  final TextEditingController cityNameController = TextEditingController();

  StreamController<String> notificationCtrl = StreamController.broadcast();
  Stream<String> get blocNotifications => notificationCtrl.stream;

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
    notificationCtrl.close();
  }

  void onFavoritePressed(DogPost post) async {
    FavoriteType type;
    if (post.runtimeType == MatePost) {
      type = FavoriteType.mating;
    } else if (post.runtimeType == AdoptPost) {
      type = FavoriteType.adoption;
    } else {
      throw PlatformException(code: '${post.runtimeType} is Not allowed');
    }

    try {
      //Save locally
      _localStorage.toggleFavorites(
        post.id,
        type,
      );

      //update the local and online user object with the new favs list

      User user = _localStorage.getUser();

      if (type == FavoriteType.adoption) {
        user.favAdoptionPosts = _localStorage.getFavorites(type);
      } else {
        user.favMatingPosts = _localStorage.getFavorites(type);
      }

      _localStorage.editUser(user);

      //Save to network
      if (_localStorage.isAuthenticated()) {
        if (type == FavoriteType.adoption) {
          FirestoreService().saveUserFavs(
              userId: user.uid, adoptionList: user.favAdoptionPosts);
        } else {
          FirestoreService()
              .saveUserFavs(userId: user.uid, matingList: user.favMatingPosts);
        }
      }
    } on PlatformException catch (e, s) {
      sentry.captureException(exception: e, stackTrace: s);
      notificationCtrl.sink.add('Error while saving favorites');
    } on SocketException {
      notificationCtrl.sink.add('Network error while saving favorites');
      stateCtrl.sink.add(DataState.networkError);
    }
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
          bool isServiceEnabled = await LocationUtil()
              .isLocationServiceEnabled()
              .timeout(Duration(seconds: 5), onTimeout: () => null);

          if (isServiceEnabled == null) {
            stateCtrl.sink.add(DataState.locationUnknownError);
            _fetchingLocation = false;
            return;
          }

          if (!isServiceEnabled) {
            stateCtrl.sink.add(DataState.locationServiceOff);
            _fetchingLocation = false;
            return;
          }

          bool permissionGranted = await checkAndAskPermission(
                  permission: Permission.locationWhenInUse)
              .timeout(Duration(seconds: 5), onTimeout: () => null);

          if (permissionGranted == null) {
            stateCtrl.sink.add(DataState.locationUnknownError);
            _fetchingLocation = false;
            return;
          }

          if (!permissionGranted) {
            stateCtrl.sink.add(DataState.locationDenied);
            _fetchingLocation = false;
            return;
          }

          UserLocationData locationData =
              await LocationUtil().getInfoFromPosition().timeout(
                    Duration(seconds: 10),
                    onTimeout: () => null,
                  );

          if (locationData == null) {
            stateCtrl.sink.add(DataState.locationUnknownError);
          } else {
            town = locationData.userTown;
            city = locationData.userCity;
            district = locationData.userDistrict;

            _localStorage.setUserLocationData(locationData);

            notificationCtrl.sink
                .add('Showing results in ${town ?? city ?? district}');

            await getPosts();
          }
        } else {
          stateCtrl.sink.add(DataState.locationNetworkError);
        }
      } on SocketException {
        stateCtrl.sink.add(DataState.locationNetworkError);
      } on PlatformException catch (e, s) {
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
