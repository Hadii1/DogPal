import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/models/dog.dart';

abstract class DogPost<T extends Dog> {
  String description;

  Timestamp dateAdded;

  String city;

  String district;

  String town;

  String locationDisplay;

  String id;

  String type;

  T dog;
}

enum PostType {
  lost,
  adopt,
  mate,
}
