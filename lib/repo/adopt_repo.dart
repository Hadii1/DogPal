import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/pagination_util.dart';
import 'package:flutter/foundation.dart';
import 'package:dog_pal/utils/extensions_util.dart';

class AdoptRepo extends PaginationUtil {
  AdoptRepo() {
    _db = FirestoreService.getInstance();
  }

  Firestore _db;

  @override
  Query firstQuery;

  @override
  Query secondQuery;

  @override
  Query thirdQuery;

  Future<List<DocumentSnapshot>> getAdoptionDogs({
    @required String town,
    @required String city,
    @required String district,
    @required String gender,
    @required String breed,
    @required List<String> coatColors,
    @required String trainingLevel,
    @required String energyLevel,
    @required String barkTendencies,
    @required String size,
  }) async {
    town == null
        ? firstQuery = null
        : firstQuery = _db
            .collection(FirestoreConsts.ADOPTION_DOGS)
            .where(PostsConsts.TOWN, isEqualTo: town)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyAdoptFilters(
                gender: gender,
                breed: breed,
                coatColors: coatColors,
                trainingLevel: trainingLevel,
                energyLevel: energyLevel,
                barkTendencies: barkTendencies,
                size: size);

    city == null
        ? secondQuery = null
        : secondQuery = _db
            .collection(FirestoreConsts.ADOPTION_DOGS)
            .where(PostsConsts.CITY, isEqualTo: city)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyAdoptFilters(
                gender: gender,
                breed: breed,
                coatColors: coatColors,
                trainingLevel: trainingLevel,
                energyLevel: energyLevel,
                barkTendencies: barkTendencies,
                size: size);

    district == null
        ? thirdQuery = null
        : thirdQuery = _db
            .collection(FirestoreConsts.ADOPTION_DOGS)
            .where(PostsConsts.DISTRICT, isEqualTo: district)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyAdoptFilters(
                gender: gender,
                breed: breed,
                coatColors: coatColors,
                trainingLevel: trainingLevel,
                energyLevel: energyLevel,
                barkTendencies: barkTendencies,
                size: size);

    return await super.getDogs();
  }

  @override
  Future<List<DocumentSnapshot>> loadMoreData() async {
    return await super.loadMoreData();
  }
}
