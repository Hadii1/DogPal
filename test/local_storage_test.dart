import 'dart:convert';
import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LocalStorage localStorage;

  setUp(() {
    localStorage = LocalStorage();
  });

  test('User Location Data Parsing and reading', () async {
    var data = LocationData(
      city: 'Beirut',
      display: 'Beirut',
      district: 'Baabda',
      town: 'Haret Hreik',
    );

    SharedPreferences.setMockInitialValues({
      LocalStorage.USER_LOCATION: json.encode(
        LocationData.toJson(data),
      )
    });

    LocationData locationData = localStorage.getUserLocationData();
    expect(locationData.city, 'Beirut');
    expect(locationData.display, 'Beirut');
    expect(locationData.district, 'Baabda');
    expect(locationData.town, 'Haret Hreik');
  });

  test('Post Location Data Parsing and reading', () async {
    var data = LocationData(
      city: 'Beirut',
      display: 'Beirut',
      district: 'Baabda',
      town: 'Haret Hreik',
    );

    SharedPreferences.setMockInitialValues({
      LocalStorage.POST_LOCATION: json.encode(
        LocationData.toJson(data),
      )
    });

    LocationData locationData = localStorage.getPostLocationData();

    expect(locationData.city, 'Beirut');
    expect(locationData.display, 'Beirut');
    expect(locationData.district, 'Baabda');
    expect(locationData.town, 'Haret Hreik');
  });

  test('User parsing and reading', () async {
    var user = User(
      email: 'Hadi.hammoud@live.com',
      photo: 'photoUrl',
      uid: '123',
      username: 'Hadi',
      dataJoined: DateTime(2020, 5, 24).toString(),
      favAdoptionPosts: [],
      favMatingPosts: ['987654321'],
      firstName: 'Hadi',
      phoneNumber: '010203',
    );

    SharedPreferences.setMockInitialValues({
      LocalStorage.USER: json.encode(
        User.toMap(user),
      )
    });

    User userData = localStorage.getUser();

    expect(userData.email, 'Hadi.hammoud@live.com');
    expect(userData.photo, 'photoUrl');
    expect(userData.uid, '123');
    expect(user.dataJoined, DateTime(2020, 5, 24).toString());
    expect(userData.favAdoptionPosts, []);
    expect(userData.favMatingPosts, ['987654321']);
    expect(userData.phoneNumber, '010203');
  });

  test('default values are true', () async {
    SharedPreferences.setMockInitialValues({});

    //isAuthenticated is false by default and isFirstTime is true

    expect(localStorage.isAuthenticated(), false);
    expect(localStorage.isFirstLaunch(), true);

    expect(
        localStorage.getPostLocationData(), localStorage.defaultPostLocation);
    expect(
        localStorage.getUserLocationData(), localStorage.defaultUserLocation);

    //empty favorite lists if null
    expect(localStorage.getFavorites(FavoriteType.adoption), hasLength(0));
    expect(localStorage.getFavorites(FavoriteType.mating), hasLength(0));
  });
}
