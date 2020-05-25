import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/auth_service.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/services.dart';

enum ProfileScreenState {
  loading,
  error,
  unAuthenticated,
  authenticated,
}

//The state of user posts and user favorites
enum UserDataState {
  loadingWithNoData,
  loadingWithData,
  postsReady,
  errorWithNoData,
  errorWithData,
}

class ProfileBloc implements BlocBase {
  ProfileBloc(this._localStorage) {
    //Used to detect when the users signs out
    _authService.authState.listen(
      (user) {
        if (user == null) {
          _screenStateCtrl.sink.add(ProfileScreenState.unAuthenticated);
          _localStorage.setAuthentication(false);
        } else {
          _screenStateCtrl.sink.add(ProfileScreenState.authenticated);
        }
      },
    );
  }

  final LocalStorage _localStorage;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  StreamController<ProfileScreenState> _screenStateCtrl =
      StreamController.broadcast();

  Stream<ProfileScreenState> get screenStateStream => _screenStateCtrl.stream;

  StreamController<UserDataState> _dataStateCtrl = StreamController.broadcast();

  Stream<UserDataState> get dataStateStream => _dataStateCtrl.stream;

  //used for cache
  List<DocumentSnapshot> userPosts = [];
  List<DocumentSnapshot> favs = [];

  //for presereving scroll positions
  double adoptFavsScrollPos = 0;
  double mateFavsScrollPos = 0;

  //for protecting from multiple simultaneous clicks
  bool _deletingAccount = false;

  String errorMsg;

  @override
  void dispose() {
    _screenStateCtrl.close();
    _dataStateCtrl.close();
  }

  void signOutPressed() async {
    _screenStateCtrl.sink.add(ProfileScreenState.loading);
    if (await isOnline()) {
      try {
        await _authService.signOut().timeout(
          Duration(seconds: 8),
          onTimeout: () {
            errorMsg = Random().nextInt(2) == 0
                ? 'Your network is causing some problems'
                : 'Poor Internet Connection';

            _screenStateCtrl.sink.add(ProfileScreenState.error);
          },
        );
        //if successful it triggers the authStateStream above
      } on PlatformException catch (_) {
        errorMsg = Random().nextInt(2) == 0
            ? 'An Error Occured'
            : 'We\'re having some problems on our side';

        _screenStateCtrl.sink.add(ProfileScreenState.error);
      } on SocketException {
        errorMsg = Random().nextInt(2) == 0
            ? 'Your network is causing some problems'
            : 'Poor Internet Connection';
        _screenStateCtrl.sink.add(ProfileScreenState.error);
      }
    } else {
      errorMsg = Random().nextInt(2) == 0
          ? 'No Internet Connection'
          : 'You\'re offline';

      _screenStateCtrl.sink.add(ProfileScreenState.error);
    }
  }

  Future<void> deleteAccountPressed() async {
    String uid = _localStorage.getUser().uid;
    if (!_deletingAccount) {
      _deletingAccount = true;
      _screenStateCtrl.sink.add(ProfileScreenState.loading);
      try {
        if (await isOnline()) {
          await _firestoreService.deleteUserData(uid);

          await _authService.signOut();

          _localStorage.setAuthentication(false);

          //if successful it triggers the authStateStream above

        } else {
          errorMsg = 'Your\'re offline';
          _screenStateCtrl.sink.add(ProfileScreenState.error);
        }
      } on SocketException {
        errorMsg = 'Poor Intrenet Connection';
        _screenStateCtrl.sink.add(ProfileScreenState.error);
      } on PlatformException catch (e, s) {
        print(e.code);
        print(e.message);
        errorMsg = 'Something went wrong. Please try again.';
        _screenStateCtrl.sink.add(ProfileScreenState.error);
        sentry.captureException(exception: e, stackTrace: s);
      }

      _deletingAccount = false;
    }
  }

  Future<void> initUserPosts() async {
    assert(_localStorage.getUser() != null,
        'This can\'t be  called when the user is not authenticated by design');
    try {
      if (await isOnline()) {
        if (userPosts.isEmpty) {
          _dataStateCtrl.sink.add(UserDataState.loadingWithNoData);
        } else {
          _dataStateCtrl.sink.add(UserDataState.loadingWithData);
        }

        String userUid = _localStorage.getUser().uid;

        List<DocumentSnapshot> newPosts =
            await _firestoreService.fetchUserPosts(userUid);

        userPosts = newPosts;
        _dataStateCtrl.sink.add(UserDataState.postsReady);
      } else {
        errorMsg = 'You\'re Offline';

        _dataStateCtrl.sink.add(userPosts.isEmpty
            ? UserDataState.errorWithNoData
            : UserDataState.errorWithData);
      }
    } on PlatformException catch (e) {
      print(e.message ?? e.code);
      errorMsg = 'An error occurred on our side';
      _dataStateCtrl.sink.add(userPosts.isEmpty
          ? UserDataState.errorWithNoData
          : UserDataState.errorWithData);
    } on SocketException {
      errorMsg = Random().nextInt(2) == 0
          ? 'Your network is causing some problems'
          : 'Poor Internet Connection';

      _dataStateCtrl.sink.add(userPosts.isEmpty
          ? UserDataState.errorWithNoData
          : UserDataState.errorWithData);
    }
  }

  List<DogPost> filterPosts(String postType) {
    List<DocumentSnapshot> list = userPosts.where(
      (doc) {
        return doc.data[PostsConsts.POST_TYPE] == postType;
      },
    ).toList();

    if (postType == 'lost') {
      return list.map(
        (doc) {
          return LostPost.fromDocument(doc.data);
        },
      ).toList();
    } else if (postType == 'mate') {
      return list.map(
        (doc) {
          return MatePost.fromMap(doc.data);
        },
      ).toList();
    } else if (postType == 'adopt') {
      return list.map(
        (doc) {
          return AdoptPost.fromDocument(doc.data);
        },
      ).toList();
    } else {
      return null;
    }
  }

  Future<void> initFavs() async {
    _dataStateCtrl.sink.add(UserDataState.loadingWithNoData);
    try {
      if (await isOnline()) {
        if (favs.isEmpty) {
          _dataStateCtrl.sink.add(UserDataState.loadingWithNoData);
        } else {
          _dataStateCtrl.sink.add(UserDataState.loadingWithData);
        }

        List<String> adoptFavs =
            _localStorage.getFavorites(FavoriteType.adoption);
        List<String> mateFavs = _localStorage.getFavorites(FavoriteType.mating);

        List<DocumentSnapshot> newPosts =
            await _firestoreService.fetchAllUserFavs(adoptFavs, mateFavs);

        favs = newPosts;

        _dataStateCtrl.sink.add(UserDataState.postsReady);
      } else {
        errorMsg = 'You\'re Offline';

        _dataStateCtrl.sink.add(favs.isEmpty
            ? UserDataState.errorWithNoData
            : UserDataState.errorWithData);
      }
    } on PlatformException catch (e) {
      print(e.message ?? e.code);

      errorMsg = Random().nextInt(2) == 0
          ? 'An error occured'
          : 'We\'re having some problems getting your data';

      _dataStateCtrl.sink.add(favs.isEmpty
          ? UserDataState.errorWithNoData
          : UserDataState.errorWithData);
    } on SocketException {
      errorMsg = Random().nextInt(2) == 0
          ? 'Your network is causing some problems'
          : 'Poor Internet Connection';

      _dataStateCtrl.sink.add(favs.isEmpty
          ? UserDataState.errorWithNoData
          : UserDataState.errorWithData);
    }
  }

  List<DogPost> filterFavs(FavoriteType type) {
    if (type == FavoriteType.adoption) {
      List<DocumentSnapshot> list = favs.where(
        (doc) {
          return doc.data[PostsConsts.POST_TYPE] == 'adopt' &&
              _localStorage
                  .getFavorites(type)
                  .contains(doc.data[PostsConsts.POST_ID]);
        },
      ).toList();

      return list.map(
        (e) {
          return AdoptPost.fromDocument(e.data);
        },
      ).toList();
    } else {
      List<DocumentSnapshot> list = favs.where(
        (doc) {
          return doc.data[PostsConsts.POST_TYPE] == 'mate' &&
              _localStorage
                  .getFavorites(type)
                  .contains(doc.data[PostsConsts.POST_ID]);
        },
      ).toList();

      return list.map(
        (e) {
          return MatePost.fromMap(e.data);
        },
      ).toList();
    }
  }

  void removeFromFavs(String id) {
    favs.removeWhere(
      (doc) {
        return doc.data[PostsConsts.POST_ID] == id;
      },
    );

    _dataStateCtrl.sink.add(UserDataState.postsReady);
  }

  void updatePostsList(String id) {
    userPosts.removeWhere((doc) {
      return doc.data[PostsConsts.POST_ID] == id;
    });
    _dataStateCtrl.sink.add(UserDataState.postsReady);
  }
}
