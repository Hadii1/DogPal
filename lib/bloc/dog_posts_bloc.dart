import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/repo/adopt_repo.dart';
import 'package:dog_pal/repo/lost_repo.dart';
import 'package:dog_pal/repo/mate_repo.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';

class DogPostsBloc implements BlocBase {
  DogPostsBloc({
    @required this.localStorage,
  }) {
    LocationData data = localStorage.getUserLocationData();
    _town = data.town;
    _city = data.city;
    _district = data.district;

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
  final LocalStorage localStorage;
  final MateRepo _mateRepo = MateRepo();
  final AdoptRepo _adoptRepo = AdoptRepo();
  final LostRepo _lostRepo = LostRepo();
  final PageController pageController = PageController();
  final TextEditingController cityNameController = TextEditingController();
  final LocationUtil _locationUtil = LocationUtil();

  StreamController<String> _notificationCtrl = StreamController.broadcast();
  Stream<String> get blocNotifications => _notificationCtrl.stream;

  //When a location suggestion is pressed we want to show the fab and filter buttons
  //so we hook this stream to the animated header widget and re-render it
  //when a suggestion is pressed
  StreamController<bool> _shouldShowHeader = StreamController.broadcast();
  Stream<bool> get showHeader => _shouldShowHeader.stream;

  StreamController<int> _activeFilterCtrl = StreamController.broadcast();
  Stream<int> get activeFilters => _activeFilterCtrl.stream;

  StreamController<DataState> stateCtrl = StreamController.broadcast();
  Stream<DataState> get dataState => stateCtrl.stream;

  StreamController<String> _postTypeCtrl = StreamController.broadcast();
  Stream<String> get postType => _postTypeCtrl.stream;

  StreamController<String> _locationCtrl = StreamController.broadcast();
  Stream<String> get location => _locationCtrl.stream;

  int filters = 0;

  List<DogPost> posts;

  bool _fetchingLocation = false;
  bool _isFetchingMorePosts = false;

  PostType postsType = PostType.adopt;

  String _town;
  String _district;
  String _city;

  //All filters:

  String gender = '';
  String breed = '';
  String size = '';
  List<String> colors = [];
  String trainingLevel = '';
  String energyLevel = '';
  String barkTendencies = '';

  bool isHalfScrolled() {
    double maxScroll = pageController.position.maxScrollExtent;
    double currentScroll = pageController.position.pixels;
    return maxScroll - currentScroll <= maxScroll * 0.4;
  }

  @override
  void dispose() {
    stateCtrl.close();
    _shouldShowHeader.close();
    pageController.dispose();
    _postTypeCtrl.close();
    _locationCtrl.close();
    _activeFilterCtrl.close();
    _notificationCtrl.close();
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
      localStorage.toggleFavorites(
        post.id,
        type,
      );

      //update the local and online user object with the new favs list

      User user = localStorage.getUser();

      if (type == FavoriteType.adoption) {
        user.favAdoptionPosts = localStorage.getFavorites(type);
      } else {
        user.favMatingPosts = localStorage.getFavorites(type);
      }

      localStorage.editUser(user);

      //Save to network
      if (localStorage.isAuthenticated()) {
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
      _notificationCtrl.sink.add('Error while saving favorites');
    } on SocketException {
      _notificationCtrl.sink.add('Network error while saving favorites');
      stateCtrl.sink.add(DataState.networkError);
    }
  }

  Future<List<Prediction>> onLocationSearch(String input) async {
    return await _locationUtil.completePlacesQuery(input);
  }

  Future<void> onSuggestionSelected(Prediction prediction) async {
    try {
      Map<String, String> info =
          await _locationUtil.getDetailsFromPrediction(prediction);

      if (info == null) {
        _notificationCtrl.sink.add('Something went wrong on our side');
        return;
      }

      _town = info[UserConsts.TOWN];
      _city = info[UserConsts.CITY];
      _district = info[UserConsts.DISTRICT];

      _locationCtrl.sink.add(prediction.description);

      getPosts();
    } on SocketException {
      _notificationCtrl.sink.add('Poor Internet Connection');
    } on PlatformException {
      _notificationCtrl.sink.add('Something went wrong on our side');
    }
  }

  void onPostTypeChanded(PostType type) {
    String typeDisplay;

    switch (type) {
      case PostType.lost:
        typeDisplay = 'Lost Dogs';
        break;
      case PostType.adopt:
        typeDisplay = 'Adoption Dogs';
        break;
      case PostType.mate:
        typeDisplay = 'Mating Dogs';
        break;
    }

    _postTypeCtrl.sink.add(typeDisplay);
    postsType = type;
    getPosts();
    clearAllFilters();
  }

  void clearAllFilters() {
    gender = '';
    breed = '';
    size = '';
    colors = [];
    trainingLevel = '';
    energyLevel = '';
    barkTendencies = '';

    getPosts();
  }

  void recountFilters() {
    int i = 0;
    switch (postsType) {
      case PostType.lost:
        if (gender.isNotEmpty) i++;
        if (breed.isNotEmpty) i++;
        if (colors.isNotEmpty) i++;
        break;

      case PostType.adopt:
        if (gender.isNotEmpty) i++;
        if (breed.isNotEmpty) i++;
        if (colors.isNotEmpty) i++;
        if (trainingLevel.isNotEmpty) i++;
        if (energyLevel.isNotEmpty) i++;
        if (barkTendencies.isNotEmpty) i++;
        if (size.isNotEmpty) i++;
        break;

      case PostType.mate:
        if (gender.isNotEmpty) i++;
        if (size.isNotEmpty) i++;
        if (breed.isNotEmpty) i++;
        if (colors.isNotEmpty) i++;
        break;
    }

    print(i);
    _activeFilterCtrl.sink.add(i);
  }

  Future<void> getPosts() async {
    recountFilters();
    stateCtrl.sink.add(DataState.loading);
    try {
      List<DocumentSnapshot> list;
      if (await isOnline()) {
        switch (postsType) {
          case PostType.lost:
            list = await _lostRepo.getLostDogs(
              town: _town,
              city: _city,
              district: _district,
              breed: breed,
              colors: colors,
              gender: gender,
            );

            break;

          case PostType.adopt:
            list = await _adoptRepo.getAdoptionDogs(
              town: _town,
              city: _city,
              district: _district,
              gender: gender,
              breed: breed,
              coatColors: colors,
              trainingLevel: trainingLevel,
              energyLevel: energyLevel,
              barkTendencies: barkTendencies,
              size: size,
            );

            break;

          case PostType.mate:
            list = await _mateRepo.getMatingDogs(
              town: _town,
              city: _city,
              district: _district,
              gender: gender,
              size: size,
              breed: breed,
              colors: colors,
            );

            break;
        }

        if (list == null) {
          stateCtrl.sink.add(DataState.unknownError);
          return;
        }

        if (list.isEmpty) {
          stateCtrl.sink.add(DataState.noDataAvailable);
          return;
        }

        switch (postsType) {
          case PostType.lost:
            posts = list.map((doc) {
              return LostPost.fromMap(doc.data);
            }).toList();
            break;

          case PostType.adopt:
            posts = list.map((doc) {
              return AdoptPost.fromMap(doc.data);
            }).toList();
            break;

          case PostType.mate:
            posts = list.map((doc) {
              return MatePost.fromMap(doc.data);
            }).toList();
            break;
        }

        stateCtrl.sink.add(DataState.postsAvailable);
      } else {
        stateCtrl.sink.add(DataState.networkError);
      }
    } on PlatformException catch (e, s) {
      sentry.captureException(
        exception: e,
        stackTrace: s,
      );
      print(e.code);
      print(e.message);

      stateCtrl.sink.add(DataState.unknownError);
    } on SocketException {
      stateCtrl.sink.add(DataState.networkError);
    }
  }

  Future<void> loadMorePosts() async {
    if (!_isFetchingMorePosts) {
      _isFetchingMorePosts = true;
      try {
        List<DocumentSnapshot> list;
        switch (postsType) {
          case PostType.lost:
            list = await _lostRepo.loadMoreData();
            break;

          case PostType.adopt:
            list = await _adoptRepo.loadMoreData();
            break;

          case PostType.mate:
            list = await _mateRepo.loadMoreData();
            break;
        }

        if (list != null && list.isNotEmpty) {
          switch (postsType) {
            case PostType.lost:
              posts = list.map((doc) => LostPost.fromMap(doc.data)).toList();
              break;

            case PostType.adopt:
              posts = list.map((doc) => AdoptPost.fromMap(doc.data)).toList();
              break;

            case PostType.mate:
              posts = list.map((doc) => MatePost.fromMap(doc.data)).toList();
              break;
          }
          stateCtrl.sink.add(DataState.postsAvailable);
        }
      } on SocketException {
        _notificationCtrl.sink.add('You\'re Internet Connection is poor.');
      }

      /*/*/* when data is updated, the widget rebuild takes
       time and so the scroll controller doesn't instantly 
       update it's scrolling values and directly makes
       another call to get more data thus doing two batches 
       of data in one scrolling session */*/*/
      Future.delayed(Duration(milliseconds: 100), () {
        _isFetchingMorePosts = false;
      });
    }
  }

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

          LocationData locationData =
              await LocationUtil().getInfoFromPosition().timeout(
                    Duration(seconds: 10),
                    onTimeout: () => null,
                  );

          if (locationData == null) {
            stateCtrl.sink.add(DataState.locationUnknownError);
          } else {
            _town = locationData.town;
            _city = locationData.city;
            _district = locationData.district;

            localStorage.setUserLocationData(locationData);

            _locationCtrl.sink.add(locationData.display);
            _notificationCtrl.sink
                .add('Showing results in ${_town ?? _city ?? _district}');

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

  void onUserPostAdded(DogPost post) {
    //to search for the last post added we edit the
    //location we're searching in to the last post location

    _town = localStorage.getPostLocationData().town;
    _city = localStorage.getPostLocationData().city;
    _district = localStorage.getPostLocationData().district;

    PostType type;
    //check last post type we added to query for this type
    switch (post.type) {
      case 'lost':
        type = PostType.lost;
        break;
      case 'adopt':
        type = PostType.adopt;
        break;
      case 'mate':
        type = PostType.mate;
        break;
      default:
        throw PlatformException(code: 'post type not supported');
    }

    onPostTypeChanded(type);
  }
}
