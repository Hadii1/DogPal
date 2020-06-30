import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/extensions_util.dart';
import 'package:dog_pal/utils/pagination_util.dart';
import 'package:flutter/foundation.dart';

class LostRepo extends PaginationUtil {
  LostRepo() {
    _db = FirestoreService.getInstance();
  }

  Firestore _db;

  @override
  Query firstQuery;

  @override
  Query secondQuery;

  @override
  Query thirdQuery;

  Future<List<DocumentSnapshot>> getLostDogs({
    @required String town,
    @required String city,
    @required String district,
    @required String breed,
    @required String gender,
    @required List<String> colors,
  }) {
    town == null
        ? firstQuery = null
        : firstQuery = _db
            .collection(FirestoreConsts.LOST_DOGS)
            .where(PostsConsts.TOWN, isEqualTo: town)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyLostFilters(breed: breed, gender: gender, colors: colors);

    city == null
        ? secondQuery = null
        : secondQuery = _db
            .collection(FirestoreConsts.LOST_DOGS)
            .where(PostsConsts.CITY, isEqualTo: city)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyLostFilters(breed: breed, gender: gender, colors: colors);

    district == null
        ? thirdQuery = null
        : thirdQuery = _db
            .collection(FirestoreConsts.LOST_DOGS)
            .where(PostsConsts.DISTRICT, isEqualTo: district)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyLostFilters(breed: breed, gender: gender, colors: colors);

    return super.getDogs();
  }

  @override
  Future<List<DocumentSnapshot>> loadMoreData() async {
    return super.loadMoreData();
  }
}
