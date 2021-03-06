import 'dart:convert';

import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataRepositroy {
  bool isAuthenticated();
  void setAuthentication(bool value);

  bool isFirstLaunch();
  void setFirstLaunch(bool value);

  LocationData getUserLocationData();
  void setUserLocationData(LocationData data);

  LocationData getPostLocationData();
  void setPostLocationData(LocationData data);

  List<String> getFavorites(FavoriteType type);
  void toggleFavorites(String id, FavoriteType type);
  void addFavorite(String id, FavoriteType type);
  void clearFavorites(FavoriteType type);

  User getUser();
  void editUser(User user);
}

class LocalStorage implements LocalDataRepositroy {
  static const String IS_AUTHENTICATED = 'isAuthenticated';
  static const String FIRST_TIME = 'firstTime';
  static const String USER = 'user';
  static const String POST_LOCATION = 'postLocation';
  static const String USER_LOCATION = 'userLocation';
  static const String FAVORITE_ADOPTION = 'favoriteAdoption';
  static const String FAVORITE_MATING = 'favoriteMating';

  @visibleForTesting
  LocationData defaultUserLocation = LocationData(
    city: 'Maricopa County',
    town: 'Scottsdale',
    display: 'Scottsdale',
    district: 'Arizona',
  );

  @visibleForTesting
  LocationData defaultPostLocation = LocationData(
    city: 'Maricopa County',
    town: 'Scottsdale',
    display: 'Scottsdale',
    district: 'Arizona',
  );

  SharedPreferences _prefs;

  LocalStorage() {
    _initLocalStorage();
  }

  Future<void> _initLocalStorage() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> editUser(User user) async {
    if (user == null) {
      await _prefs.setString(USER, null);
    } else {
      await _prefs.setString(USER, json.encode(User.toMap(user)));
    }
  }

  @override
  User getUser() {
    if (_prefs.getString(USER) == null) {
      return null;
    } else {
      return User.fromMap(
        Map<String, dynamic>.from(
          json.decode(
            _prefs.getString(USER),
          ),
        ),
      );
    }
  }

  @override
  Future<void> toggleFavorites(String id, FavoriteType type) async {
    List<String> favs = _prefs.getStringList(type == FavoriteType.adoption
            ? FAVORITE_ADOPTION
            : FAVORITE_MATING) ??
        [];

    if (favs.contains(id)) {
      favs.removeWhere((element) => element == id);
    } else {
      favs.add(id);
    }
    _prefs.setStringList(
      type == FavoriteType.adoption ? FAVORITE_ADOPTION : FAVORITE_MATING,
      favs,
    );
  }

  @override
  void addFavorite(String id, FavoriteType type) {
    List<String> favs = _prefs.getStringList(
          type == FavoriteType.adoption ? FAVORITE_ADOPTION : FAVORITE_MATING,
        ) ??
        [];

    if (!favs.contains(id)) {
      favs.add(id);
    }

    _prefs.setStringList(
      type == FavoriteType.adoption ? FAVORITE_ADOPTION : FAVORITE_MATING,
      favs,
    );
  }

  @override
  List<String> getFavorites(FavoriteType type) {
    if (type == FavoriteType.adoption) {
      return _prefs.getStringList(FAVORITE_ADOPTION) ?? [];
    } else if (type == FavoriteType.mating) {
      return _prefs.getStringList(FAVORITE_MATING) ?? [];
    } else
      return null;
  }

  @override
  LocationData getUserLocationData() {
    if (_prefs.getString(USER_LOCATION) == null) {
      return defaultUserLocation;
    } else {
      return LocationData.fromJson(
        Map<String, String>.from(
          json.decode(_prefs.getString(USER_LOCATION)),
        ),
      );
    }
  }

  @override
  Future<void> setUserLocationData(LocationData data) async {
    _prefs.setString(USER_LOCATION, json.encode(LocationData.toJson(data)));
  }

  @override
  LocationData getPostLocationData() {
    if (_prefs.getString(POST_LOCATION) == null) {
      return defaultPostLocation;
    } else {
      return LocationData.fromJson(
        Map<String, String>.from(
          json.decode(
            _prefs.getString(POST_LOCATION),
          ),
        ),
      );
    }
  }

  @override
  void setPostLocationData(LocationData data) {
    _prefs.setString(POST_LOCATION, json.encode(LocationData.toJson(data)));
  }

  @override
  bool isAuthenticated() {
    return _prefs.getBool(IS_AUTHENTICATED) ?? false;
  }

  @override
  bool isFirstLaunch() {
    return _prefs.getBool(FIRST_TIME) ?? true;
  }

  @override
  Future<void> setAuthentication(bool value) async {
    _prefs.setBool(IS_AUTHENTICATED, value);
  }

  @override
  void setFirstLaunch(bool value) {
    _prefs.setBool(FIRST_TIME, value);
  }

  @override
  void clearFavorites(FavoriteType type) {
    _prefs.setStringList(
      type == FavoriteType.adoption ? FAVORITE_ADOPTION : FAVORITE_MATING,
      [],
    );
  }
}
