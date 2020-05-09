import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 99)
class User {
  @HiveField(0)
  String username;

  @HiveField(1)
  String email;

  @HiveField(2)
  String photo;

  @HiveField(3)
  String uid;

  @HiveField(4)
  DateTime dataJoined;

  @HiveField(5)
  Map<String, String> favoritePosts; //contains posts id and type'

  @HiveField(6)
  String phoneNumber;

  @HiveField(7)
  String firstName;

  static Map<String, dynamic> toMap(User user) => {
        UserConsts.USER_EMAIL: user.email,
        UserConsts.FIRST_NAME: user.firstName,
        UserConsts.USER_PHOTO: user.photo,
        UserConsts.USER_UID: user.uid,
        UserConsts.FAVORITE: user.favoritePosts,
        UserConsts.USERNAME: user.username,
        UserConsts.DATE_JOINED: user.dataJoined,
      };

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      dataJoined: (map[UserConsts.DATE_JOINED] as Timestamp).toDate(),
      photo: map[UserConsts.USER_PHOTO],
      username: map[UserConsts.USERNAME],
      favoritePosts: (map[UserConsts.FAVORITE] as Map).cast<String, String>(),
      firstName: map[UserConsts.FIRST_NAME] ?? map[UserConsts.USERNAME],
      uid: map[UserConsts.USER_UID],
      email: map[UserConsts.USER_EMAIL],
    );
  }

  User({
    @required this.username,
    @required this.email,
    @required this.photo,
    @required this.uid,
    this.firstName,
    this.favoritePosts,
    this.dataJoined,
    this.phoneNumber,
  });
}
