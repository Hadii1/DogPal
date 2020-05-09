import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants_util.dart';
import 'dart:math' as _Math;

extension ErrorCatching on PlatformException {
  String getAuthError() => _getErrorMsg(this);
}

String _getErrorMsg(PlatformException e) {
  print('msg: ${e.message} and code: ${e.code}');

  if (e.code == null) {
    return ('Unknown error, try again.');
  } else {
    String error;
    switch (e.code) {
      case AuthErrors.INVALID:
        error = 'Invalid Email';
        break;

      case AuthErrors.USER_NOT_FOUND:
        error = 'There is no user corresponding to this email.';
        break;

      case AuthErrors.MANY_ATTEMPTS:
        error = 'Too many attempts! try again later.';
        break;

      case AuthErrors.WRONG_PASSWORD:
        error = 'The password is incorrect.';
        break;

      case AuthErrors.EMAIL_IN_USE:
        error = 'The email entered is already in use.';
        break;

      case AuthErrors.WEAK_PASSWORD:
        error = 'The password is weak.';
        break;

      case AuthErrors.ACCOUNT_EXISTS:
        error =
            'An account already exists with this email address, please sign in using the other option.';
        break;

      case AuthErrors.NETWORK_ERROR:
        error = 'Network error occured, try again.';
        break;

      default:
        error = 'Unknown error, try again.';
        break;
    }

    return error;
  }
}

extension AngleConversion on double {
  double toRadian() => _convertToRadians(this);
}

double _convertToRadians(double degree) {
  return double.parse((degree * (_Math.pi / 180)).toStringAsFixed(9));
}

extension DeleteDuplicated on List<DocumentSnapshot> {
  List<DocumentSnapshot> deDup() => _removeDuplicated(this);
}

List<DocumentSnapshot> _removeDuplicated(List<DocumentSnapshot> list) {
  Set seen = Set();
  List<DocumentSnapshot> finalList = [];
  
  for (DocumentSnapshot doc in list) {
    if (!seen.contains(doc.documentID)) {
      seen.add(doc.documentID);
      finalList.add(doc);
    }
  }

  return finalList;
}

extension QueryFilter on Query {
  Query applyLostFilters({
    @required String breed,
    @required String gender,
    @required List<String> colors,
  }) =>
      _applyLostFilters(breed, gender, colors, this);

  Query applyAdoptFilters({
    @required String gender,
    @required String breed,
    @required List<String> coatColors,
    @required String trainingLevel,
    @required String energyLevel,
    @required String barkTendencies,
    @required String size,
  }) =>
      _applyAdoptFilters(
        gender: gender,
        breed: breed,
        coatColors: coatColors,
        trainingLevel: trainingLevel,
        energyLevel: energyLevel,
        barkTendencies: barkTendencies,
        size: size,
        query: this,
      );

  Query applyMateFilters({
    @required String gender,
    @required String breed,
    @required List<String> colors,
    @required String size,
  }) =>
      _applyMateFilters(
        gender: gender,
        size: size,
        colors: colors,
        breed: breed,
        query: this,
      );
}

Query _applyMateFilters({
  String gender,
  String breed,
  String size,
  List<String> colors,
  Query query,
}) {
  if (gender.isNotEmpty) {
    query = query.where(DogConsts.GENDER, isEqualTo: gender);
  }
  if (breed.isNotEmpty) {
    query = query.where(DogConsts.DOG_BREED, isEqualTo: breed);
  }
  if (colors.isNotEmpty) {
    query = query.where(DogConsts.COAT_COLORS, arrayContainsAny: colors);
  }

  if (size.isNotEmpty) {
    query = query.where(DogConsts.Size, isEqualTo: size);
  }
  return query;
}

Query _applyAdoptFilters({
  String gender,
  String breed,
  List<String> coatColors,
  String trainingLevel,
  String energyLevel,
  String barkTendencies,
  String size,
  Query query,
}) {
  if (gender.isNotEmpty) {
    query = query.where(DogConsts.GENDER, isEqualTo: gender);
  }
  if (breed.isNotEmpty) {
    query = query.where(DogConsts.DOG_BREED, isEqualTo: breed);
  }
  if (coatColors.isNotEmpty) {
    query = query.where(DogConsts.COAT_COLORS, arrayContainsAny: coatColors);
  }
  if (trainingLevel.isNotEmpty) {
    query = query.where(DogConsts.TRAINING_LEVEL, isEqualTo: trainingLevel);
  }
  if (energyLevel.isNotEmpty) {
    query = query.where(DogConsts.ENERGY_LEVEL, isEqualTo: energyLevel);
  }
  if (barkTendencies.isNotEmpty) {
    query = query.where(DogConsts.BARK_TENDENCY, isEqualTo: barkTendencies);
  }
  if (size.isNotEmpty) {
    query = query.where(DogConsts.Size, isEqualTo: size);
  }
  return query;
}

Query _applyLostFilters(String breed, String gender, List colors, Query query) {
  if (gender.isNotEmpty) {
    query = query.where(DogConsts.GENDER, isEqualTo: gender);
  }
  if (colors.isNotEmpty) {
    query = query.where(DogConsts.COAT_COLORS, arrayContainsAny: colors);
  }

  if (breed.isNotEmpty) {
    query = query.where(DogConsts.DOG_BREED, isEqualTo: breed);
  }

  return query;
}
