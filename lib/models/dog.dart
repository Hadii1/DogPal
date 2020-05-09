import 'package:dog_pal/models/user.dart';
import 'package:flutter/material.dart';

class Dog {
  String dogName;
  String breed;
  List<String> imagesUrls;
  List coatColors;
  String gender;
  User owner;

  Dog({
    @required this.breed,
    @required this.coatColors,
    @required this.owner,
    @required this.gender,
    @required this.imagesUrls,
    @required this.dogName,
  });
}

class AdoptionDog implements Dog {
  String size;
  String barkTendencies;
  String sheddingLevel;
  String trainingLevel;
  String energyLevel;

  bool petFriendly;
  bool appartmentFriendly;
  bool vaccinated;
  bool pedigree;

  String age;

  @override
  String breed;

  @override
  List coatColors;

  @override
  String dogName;

  @override
  String gender;

  @override
  List<String> imagesUrls;

  @override
  User owner;

  AdoptionDog({
    @required this.gender,
    @required this.pedigree,
    @required this.owner,
    @required this.imagesUrls,
    @required this.dogName,
    @required this.breed,
    @required this.coatColors,
    @required this.appartmentFriendly,
    @required this.trainingLevel,
    @required this.size,
    @required this.barkTendencies,
    @required this.sheddingLevel,
    @required this.energyLevel,
    @required this.petFriendly,
    @required this.vaccinated,
    @required this.age,
  });
}

class MateDog implements Dog {
  String size;

  String age;

  bool vaccinated;
  bool pedigree;

  @override
  String breed;

  @override
  List coatColors;

  @override
  String dogName;

  @override
  String gender;

  @override
  List<String> imagesUrls;

  @override
  User owner;

  MateDog({
    @required this.size,
    @required this.age,
    @required this.vaccinated,
    @required this.breed,
    @required this.pedigree,
    @required this.coatColors,
    @required this.dogName,
    @required this.gender,
    @required this.imagesUrls,
    @required this.owner,
  });
}
