import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/auth_service.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sentry/sentry.dart' as _sentry;

class ProfileBloc implements BlocBase {
  ProfileBloc({@required this.localStorage}) {
    //Used to detect when the users signs out
    _authService.authState.listen(
      (user) {
        if (user == null) {
          _screenStateCtrl.sink.add(ProfileScreenState.unAuthenticated);
          localStorage.setAuthentication(false);
          localStorage.editUser(null);
        } else {
          _screenStateCtrl.sink.add(ProfileScreenState.authenticated);
        }
      },
    );
  }

  final LocalStorage localStorage;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  StreamController<ProfileScreenState> _screenStateCtrl =
      StreamController.broadcast();

  Stream<ProfileScreenState> get screenStateStream => _screenStateCtrl.stream;

  StreamController<UserDataState> _dataStateCtrl = StreamController.broadcast();

  Stream<UserDataState> get dataStateStream => _dataStateCtrl.stream;

  StreamController<String> _notificationsCtrl = StreamController();
  Stream<String> get notifications => _notificationsCtrl.stream;

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
    _notificationsCtrl.close();
  }

  void signOutPressed() async {
    _screenStateCtrl.sink.add(ProfileScreenState.loading);
    if (await isOnline()) {
      try {
        await _authService.signOut().timeout(
          Duration(seconds: 8),
          onTimeout: () {
            _notificationsCtrl.sink.add(Random().nextInt(2) == 0
                ? 'Your network is causing some problems'
                : 'Poor Internet Connection');
          },
        );
        //if successful it triggers the authStateStream above
      } on PlatformException catch (_) {
        _notificationsCtrl.sink.add(Random().nextInt(2) == 0
            ? 'An Error Occured'
            : 'We\'re having some problems on our side');
      } on SocketException {
        _notificationsCtrl.sink.add(Random().nextInt(2) == 0
            ? 'Your network is causing some problems'
            : 'Poor Internet Connection');
      }
    } else {
      _notificationsCtrl.sink.add(Random().nextInt(2) == 0
          ? 'No Internet Connection'
          : 'You\'re offline');
    }
  }

  Future<void> onUserPostAdded() => initUserPosts();

  Future<void> deleteAccountPressed() async {
    String uid = localStorage.getUser().uid;
    if (!_deletingAccount) {
      _deletingAccount = true;
      _screenStateCtrl.sink.add(ProfileScreenState.loading);
      try {
        if (await isOnline()) {
          // log to see how many users are deleting accounts
          sentry.capture(
            event: _sentry.Event(
              loggerName: 'User Delete Account',
              userContext: _sentry.User(
                username: localStorage.getUser().username,
                email: localStorage.getUser().email,
                id: localStorage.getUser().uid,
                extras: {
                  'Deleted at': DateTime.now().toString(),
                },
              ),
            ),
          );

          // delete data and sign out

          await _firestoreService.deleteUserData(uid);
          await _authService.signOut();
          localStorage.setAuthentication(false);

          //if successful it triggers the authStateStream above

        } else {
          _notificationsCtrl.sink.add('Your\'re offline');
        }
      } on SocketException {
        _notificationsCtrl.sink.add('Poor Intrenet Connection');
      } on PlatformException catch (e, s) {
        print(e.code);
        print(e.message);

        _notificationsCtrl.sink.add('Something went wrong. Please try again.');
        sentry.captureException(exception: e, stackTrace: s);
      }

      _deletingAccount = false;
    }
  }

  Future<void> initUserPosts() async {
    assert(localStorage.getUser() != null,
        'This can\'t be  called when the user is not authenticated by design');
    try {
      if (await isOnline()) {
        if (userPosts.isEmpty) {
          _dataStateCtrl.sink.add(UserDataState.loadingWithNoData);
        } else {
          _dataStateCtrl.sink.add(UserDataState.loadingWithData);
        }

        String userUid = localStorage.getUser().uid;

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
          return LostPost.fromMap(doc.data);
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
          return AdoptPost.fromMap(doc.data);
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
            localStorage.getFavorites(FavoriteType.adoption);
        List<String> mateFavs = localStorage.getFavorites(FavoriteType.mating);

        List<DocumentSnapshot> adoptPosts = await FirestoreService()
            .getFavroiteList(adoptFavs, FirestoreConsts.ADOPTION_DOGS);

        List<DocumentSnapshot> matePosts = await FirestoreService()
            .getFavroiteList(mateFavs, FirestoreConsts.MATE_DOGS);

        favs.clear();
        favs.addAll(matePosts);
        favs.addAll(adoptPosts);

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

      _dataStateCtrl.sink.add(
        favs.isEmpty
            ? UserDataState.errorWithNoData
            : UserDataState.errorWithData,
      );
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
    List<DocumentSnapshot> list;
    if (type == FavoriteType.adoption) {
      list = favs.where(
        (doc) {
          return doc.data[PostsConsts.POST_TYPE] == 'adopt' &&
              localStorage
                  .getFavorites(type)
                  .contains(doc.data[PostsConsts.POST_ID]);
        },
      ).toList();

      return list.map(
        (e) {
          return AdoptPost.fromMap(e.data);
        },
      ).toList();
    } else {
      list = favs.where(
        (doc) {
          return doc.data[PostsConsts.POST_TYPE] == 'mate' &&
              localStorage
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

  void onFavoritePressed(DogPost post) async {
    FavoriteType type;
    if (post.type == 'mate') {
      type = FavoriteType.mating;
    } else if (post.type == 'adopt') {
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

      User user = localStorage.getUser();

      //edit the local user object
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
      _notificationsCtrl.sink.add('An error occured while saving favorites');
    } on SocketException {
      _notificationsCtrl.sink.add('Network error while saving favorites');
    }

    _dataStateCtrl.sink.add(UserDataState.postsReady);
  }
}
