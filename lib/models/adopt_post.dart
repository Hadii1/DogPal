import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:flutter/foundation.dart';
import 'dog_post_mode.dart';

class AdoptPost implements DogPost<AdoptionDog> {
  @override
  AdoptionDog dog;

  @override
  String type;

  @override
  String city;

  @override
  String town;

  @override
  String id;

  @override
  Timestamp dateAdded;

  @override
  String description;

  @override
  String district;

  @override
  String locationDisplay;

  factory AdoptPost.fromMap(Map map) {
    return AdoptPost(
      id: map[PostsConsts.POST_ID],
      city: map[PostsConsts.CITY],
      town: map[PostsConsts.TOWN],
      district: map[PostsConsts.DISTRICT],
      locationDisplay: map[PostsConsts.LOCATION_DISPLAY],
      dateAdded: map[PostsConsts.DATE_ADDED],
      type: 'adopt',
      description: map[PostsConsts.DESCRIPTION],
      dog: AdoptionDog(
          pedigree: map[DogConsts.PEDIGREE],
          age: map[DogConsts.AGE],
          appartmentFriendly: map[DogConsts.APPARTMENT_FRIENDLY],
          barkTendencies: map[DogConsts.BARK_TENDENCY],
          breed: map[DogConsts.DOG_BREED],
          coatColors: map[DogConsts.COAT_COLORS],
          dogName: map[DogConsts.DOG_NAME],
          energyLevel: map[DogConsts.ENERGY_LEVEL],
          gender: map[DogConsts.GENDER],
          imagesUrls: (map[DogConsts.IMAGES] as List).cast<String>(),
          petFriendly: map[DogConsts.PET_FRIENDLY],
          sheddingLevel: map[DogConsts.SHEDDING_LEVEL],
          size: map[DogConsts.Size],
          trainingLevel: map[DogConsts.TRAINING_LEVEL],
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

  static Map<String, dynamic> toDocument(AdoptPost post) => {
        PostsConsts.LOCATION_DISPLAY: post.locationDisplay,
        DogConsts.AGE: post.dog.age,
        PostsConsts.POST_TYPE: 'adopt',
        DogConsts.APPARTMENT_FRIENDLY: post.dog.appartmentFriendly,
        PostsConsts.POST_ID: post.id,
        PostsConsts.TOWN: post.town,
        DogConsts.PEDIGREE: post.dog.pedigree,
        DogConsts.SHEDDING_LEVEL: post.dog.sheddingLevel,
        DogConsts.COAT_COLORS: post.dog.coatColors,
        DogConsts.DOG_BREED: post.dog.breed,
        DogConsts.DOG_NAME: post.dog.dogName,
        DogConsts.ENERGY_LEVEL: post.dog.energyLevel,
        DogConsts.GENDER: post.dog.gender,
        DogConsts.BARK_TENDENCY: post.dog.barkTendencies,
        DogConsts.IMAGES: post.dog.imagesUrls,
        DogConsts.PET_FRIENDLY: post.dog.petFriendly,
        DogConsts.VACCINATED: post.dog.vaccinated,
        DogConsts.TRAINING_LEVEL: post.dog.trainingLevel,
        PostsConsts.DESCRIPTION: post.description,
        DogConsts.Size: post.dog.size,
        PostsConsts.DATE_ADDED: post.dateAdded,
        PostsConsts.DISTRICT: post.district,
        PostsConsts.CITY: post.city,
        UserConsts.USER_EMAIL: post.dog.owner.email,
        UserConsts.USERNAME: post.dog.owner.username,
        UserConsts.PHONE_NUMBER: post.dog.owner.phoneNumber,
        UserConsts.USER_PHOTO: post.dog.owner.photo,
        UserConsts.USER_UID: post.dog.owner.uid,
      };

  AdoptPost({
    this.type,
    @required this.locationDisplay,
    @required this.town,
    @required this.id,
    @required this.dog,
    @required this.city,
    @required this.district,
    @required this.dateAdded,
    @required this.description,
  });
}
