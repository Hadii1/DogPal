import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:flutter/foundation.dart';

import 'dog_post_mode.dart';

class MatePost implements DogPost<MateDog> {
  @override
  String type;

  @override
  String city;

  @override
  Timestamp dateAdded;

  @override
  String id;

  @override
  String description;

  @override
  String district;

  @override
  String town;

  @override
  MateDog dog;

  @override
  String locationDisplay;

  factory MatePost.fromMap(Map<String, dynamic> map) {
    return MatePost(
      type: 'mate',
      town: map[PostsConsts.TOWN],
      city: map[PostsConsts.CITY],
      district: map[PostsConsts.DISTRICT],
      locationDisplay: map[PostsConsts.LOCATION_DISPLAY],
      id: map[PostsConsts.POST_ID],
      dateAdded: map[PostsConsts.DATE_ADDED],
      description: map[PostsConsts.DESCRIPTION],
      dog: MateDog(
          pedigree: map[DogConsts.PEDIGREE],
          age: map[DogConsts.AGE],
          breed: map[DogConsts.DOG_BREED],
          coatColors: map[DogConsts.COAT_COLORS],
          dogName: map[DogConsts.DOG_NAME],
          gender: map[DogConsts.GENDER],
          imagesUrls: (map[DogConsts.IMAGES] as List).cast<String>(),
          size: map[DogConsts.Size],
          vaccinated: map[DogConsts.VACCINATED],
          owner: User(
            email: map[UserConsts.USER_EMAIL],
            username: map[UserConsts.USERNAME],
            phoneNumber: map[UserConsts.PHONE_NUMBER],
            photo: map[UserConsts.USER_PHOTO],
            uid: map[UserConsts.USER_UID],
          )),
    );
  }

  static Map<String, dynamic> toDocument(MatePost matePost) => {
        PostsConsts.LOCATION_DISPLAY: matePost.locationDisplay,
        UserConsts.USER_UID: matePost.dog.owner.uid,
        PostsConsts.TOWN: matePost.town,
        PostsConsts.CITY: matePost.city,
        PostsConsts.POST_TYPE: 'mate',
        PostsConsts.DATE_ADDED: matePost.dateAdded,
        PostsConsts.POST_ID: matePost.id,
        DogConsts.PEDIGREE: matePost.dog.pedigree,
        PostsConsts.DESCRIPTION: matePost.description,
        PostsConsts.DISTRICT: matePost.district,
        DogConsts.AGE: matePost.dog.age,
        DogConsts.Size: matePost.dog.size,
        DogConsts.COAT_COLORS: matePost.dog.coatColors,
        DogConsts.DOG_NAME: matePost.dog.dogName,
        DogConsts.GENDER: matePost.dog.gender,
        DogConsts.IMAGES: matePost.dog.imagesUrls,
        DogConsts.DOG_BREED: matePost.dog.breed,
        DogConsts.VACCINATED: matePost.dog.vaccinated,
        UserConsts.USER_EMAIL: matePost.dog.owner.email,
        UserConsts.USERNAME: matePost.dog.owner.username,
        UserConsts.PHONE_NUMBER: matePost.dog.owner.phoneNumber,
        UserConsts.USER_PHOTO: matePost.dog.owner.photo,
      };

  MatePost({
    this.type,
    @required this.locationDisplay,
    @required this.city,
    @required this.town,
    @required this.dateAdded,
    @required this.description,
    @required this.district,
    @required this.id,
    @required this.dog,
  });
}
