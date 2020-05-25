import 'dart:async';
import 'dart:io';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dog_pal/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:dog_pal/utils/extensions_util.dart';

enum SignInMethod {
  fb,
  gmail,
}

class AuthBloc implements BlocBase {
  AuthBloc(this._localStorage);
  AuthService _authService = AuthService();

  StreamController<String> _errorCtrl = StreamController();

  StreamController<bool> _shouldLoad = StreamController();

  StreamController<bool> _navigateCtrl = StreamController();

  Stream<bool> get shouldNavigate => _navigateCtrl.stream;

  Stream<String> get error => _errorCtrl.stream;

  Stream<bool> get loading => _shouldLoad.stream;

  bool _isLogging = false;

  LocalDataRepositroy _localStorage;

  @override
  void dispose() {
    _navigateCtrl.close();
    _errorCtrl.close();
    _shouldLoad.close();
  }

  Future<void> signIn(
    SignInMethod method,
  ) async {
    if (!_isLogging) {
      _isLogging = true;
      _shouldLoad.sink.add(true);
      try {
        if (await isOnline()) {
          FirebaseUser user;

          switch (method) {
            case SignInMethod.fb:
              user = await _authService.signInWithFb();
              break;
            case SignInMethod.gmail:
              user = await _authService.signInWithGmail();
              break;
          }

          if (user != null) {
            _localStorage.setAuthentication(true);

            await _saveUserData(user);

            _authService.clearData();

            _navigateCtrl.sink.add(true);
          }
        } else {
          _errorCtrl.sink.add(GeneralConstants.NO_INTERNET_CONNECTION);
        }
      } on PlatformException catch (e, s) {
        sentry.captureException(
          exception: e,
          stackTrace: s,
        );
        _errorCtrl.sink.add(e.getAuthError());
      } on SocketException {
        _shouldLoad.sink.add(false);
        _errorCtrl.sink.add('Poor Internet Connection. Try again.');
      }

      _isLogging = false;
      _shouldLoad.sink.add(false);
    }
  }

  Future<void> _saveUserData(FirebaseUser user) async {
    try {
      _shouldLoad.sink.add(true);

      Map<String, dynamic> oldData =
          await FirestoreService().getUserData(user.uid);

      User localUser;

      if (oldData == null) {
        //first time the user creates account
        localUser = User(
          username: user.displayName,
          email: user.email ?? _authService.userEmail,
          uid: user.uid,
          firstName: _authService.firstName,
          dataJoined: DateTime.now().toString(),
          photo: user.photoUrl ?? '',
          favAdoptionPosts: _localStorage.getFavorites(FavoriteType.adoption),
          favMatingPost: _localStorage.getFavorites(FavoriteType.mating),
          phoneNumber: '',
        );
      } else {
        //signed up before
        User oldUser = User.fromMap(oldData);

        localUser = User(
          username: user.displayName,
          firstName: _authService.firstName,
          email: user.email ?? _authService.userEmail,
          uid: user.uid,
          photo: user.photoUrl,
          dataJoined: oldUser.dataJoined ?? DateTime.now(),
          favAdoptionPosts: oldUser.favAdoptionPosts
            ..addAll(
              _localStorage.getFavorites(FavoriteType.adoption),
            ),
          favMatingPost: oldUser.favMatingPost
            ..addAll(_localStorage.getFavorites(FavoriteType.mating)),
          phoneNumber: oldUser.phoneNumber ?? user.phoneNumber ?? '',
        );

        //add online favs to local favs

        for (String a in localUser.favAdoptionPosts) {
          _localStorage.editFavorites(a, FavoriteType.adoption);
        }

        for (String a in localUser.favMatingPost) {
          _localStorage.editFavorites(a, FavoriteType.mating);
        }
      }

      await FirestoreService().saveUserData(
        User.toMap(localUser),
        localUser.uid,
      );

      _localStorage.editUser(localUser);

      _shouldLoad.sink.add(false);
    } on PlatformException catch (e, s) {
      _errorCtrl.sink.add(e.getAuthError());
      sentry.captureException(
        exception: e,
        stackTrace: s,
      );
    } on SocketException {
      _errorCtrl.sink.add('Poor Internet Connection');
    }
  }
}
