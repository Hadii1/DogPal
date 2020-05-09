import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:flutter/foundation.dart';
import 'dog_post_mode.dart';

class LostPost implements DogPost {
  Dog dog;

  @override
  String type;

  @override
  String city;

  @override
  String id;

  @override
  Timestamp dateAdded;

  @override
  String description;

  @override
  String district;

  @override
  String town;

  @override
  String locationDisplay;

  factory LostPost.fromDocument(Map map) {
    return LostPost(
      dog: Dog(
        dogName: map[DogConsts.DOG_NAME],
        gender: map[DogConsts.GENDER],
        imagesUrls: (map[DogConsts.IMAGES] as List).cast<String>(),
        breed: map[DogConsts.DOG_BREED],
        coatColors: map[DogConsts.COAT_COLORS],
        owner: User(
          email: map[UserConsts.USER_EMAIL],
          username: map[UserConsts.USERNAME],
          phoneNumber: map[UserConsts.PHONE_NUMBER],
          photo: map[UserConsts.USER_PHOTO],
          uid: map[UserConsts.USER_UID],
        ),
      ),
      locationDisplay: map[PostsConsts.LOCATION_DISPLAY],
      town: map[PostsConsts.TOWN],
      city: map[PostsConsts.CITY],
      district: map[PostsConsts.DISTRICT],
      description: map[PostsConsts.DESCRIPTION],
      type: 'lost',
      id: map[PostsConsts.POST_ID],
      dateAdded: map[PostsConsts.DATE_ADDED],
    );
  }

  static Map<String, dynamic> toDocument(LostPost post) => {
        PostsConsts.POST_TYPE: 'lost',
        PostsConsts.LOCATION_DISPLAY: post.locationDisplay,
        UserConsts.USER_EMAIL: post.dog.owner.email,
        UserConsts.USERNAME: post.dog.owner.username,
        UserConsts.PHONE_NUMBER: post.dog.owner.phoneNumber,
        UserConsts.USER_PHOTO: post.dog.owner.photo,
        UserConsts.USER_UID: post.dog.owner.uid,
        DogConsts.DOG_BREED: post.dog.breed,
        DogConsts.DOG_NAME: post.dog.dogName,
        DogConsts.GENDER: post.dog.gender,
        PostsConsts.POST_ID: post.id,
        DogConsts.IMAGES: post.dog.imagesUrls,
        DogConsts.COAT_COLORS: post.dog.coatColors,
        PostsConsts.DISTRICT: post.district,
        PostsConsts.DESCRIPTION: post.description,
        PostsConsts.CITY: post.city,
        PostsConsts.TOWN: post.town,
        PostsConsts.DATE_ADDED: post.dateAdded,
      };

  LostPost({
    this.type,
    @required this.locationDisplay,
    @required this.description,
    @required this.id,
    @required this.dog,
    @required this.dateAdded,
    @required this.district,
    @required this.town,
    @required this.city,
  });
}
