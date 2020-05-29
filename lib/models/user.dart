import 'package:dog_pal/utils/constants_util.dart';
import 'package:flutter/foundation.dart';

class User {
  String username;
  String email;
  String photo;
  String phoneNumber;
  String firstName;
  String uid;

  String dataJoined;

  List<String> favAdoptionPosts;
  List<String> favMatingPosts;

  static Map<String, dynamic> toMap(User user) => {
        UserConsts.USER_EMAIL: user.email,
        UserConsts.FIRST_NAME: user.firstName,
        UserConsts.USER_PHOTO: user.photo,
        UserConsts.USER_UID: user.uid,
        UserConsts.FAVORITE_ADOPTION: user.favAdoptionPosts,
        UserConsts.FAVORITE_MATING: user.favMatingPosts,
        UserConsts.USERNAME: user.username,
        UserConsts.DATE_JOINED: user.dataJoined,
        UserConsts.PHONE_NUMBER: user.phoneNumber,
      };

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      dataJoined: map[UserConsts.DATE_JOINED],
      photo: map[UserConsts.USER_PHOTO],
      username: map[UserConsts.USERNAME],
      favAdoptionPosts:
          (map[UserConsts.FAVORITE_ADOPTION] as List<dynamic>).cast<String>(),
      favMatingPosts:
          (map[UserConsts.FAVORITE_MATING] as List<dynamic>).cast<String>(),
      firstName: map[UserConsts.FIRST_NAME] ?? map[UserConsts.USERNAME],
      uid: map[UserConsts.USER_UID],
      email: map[UserConsts.USER_EMAIL],
      phoneNumber: map[UserConsts.PHONE_NUMBER],
    );
  }

  User({
    @required this.username,
    @required this.email,
    @required this.photo,
    @required this.uid,
    this.firstName,
    this.favAdoptionPosts,
    this.favMatingPosts,
    this.dataJoined,
    this.phoneNumber,
  });
}
