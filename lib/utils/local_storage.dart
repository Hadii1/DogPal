import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String IS_AUTHENTICATED = 'isAuthenticated';
  static const String USER_BOX = 'userBox';
  static const String FIRST_TIME = 'firstTime';
  static const String USER_INFO = 'userInfo';
  static const String POST_LOCATION_DATA = 'postLocationData';
  static const String LOCATION_DATA = 'userLocationData';
  static const String FAVORITE_POSTS = 'favoritePosts';

  static Box _userBox;

  //called once
  Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox(USER_BOX);
    _userBox = Hive.box(USER_BOX);
  }

  bool isAuthenticated() {
    return _userBox.get(IS_AUTHENTICATED, defaultValue: false);
  }

  void setAuthentication(bool value) {
    _userBox.put(IS_AUTHENTICATED, value);
  }

  void setFirstLaunch(bool value) {
    _userBox.put(FIRST_TIME, value);
  }

  void saveUserLocationData(Map<String, String> data) {
    _userBox.put(LOCATION_DATA, data);
  }

  void savePostLocationData(Map<String, String> data) {
    _userBox.put(POST_LOCATION_DATA, data);
  }

  Map<String, String> getPostLocationData() {
    Map data = _userBox.get(
      POST_LOCATION_DATA,
      defaultValue: GeneralConstants.defaultLocation,
    );

    return data.cast<String, String>();
  }

  Map<String, String> getLocationData() {
    return (_userBox.get(
      LOCATION_DATA,
      defaultValue: GeneralConstants.defaultLocation,
    ) as Map)
        .cast<String, String>();
  }

  Map<String, String> getFavorites() {
    return (_userBox.get(FAVORITE_POSTS, defaultValue: {}) as Map)
        .cast<String, String>();
  }

  void editFavorites(String id, String type) {
    Map<String, String> favs = getFavorites();

    if (favs.containsKey(id)) {
      favs.remove(id);
    } else {
      favs.addEntries([
        MapEntry(id, type),
      ]);
    }

    _userBox.put(FAVORITE_POSTS, favs);
  }

  void saveUserDetails(User user) {
    _userBox.put(USER_INFO, user);
  }

  User getUser() {
    User user = _userBox.get(USER_INFO, defaultValue: null);
    return user;
  }

  bool isFirstLaunch() {
    return _userBox.get(FIRST_TIME, defaultValue: true);
  }
}
