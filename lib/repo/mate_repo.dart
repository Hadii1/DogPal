import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/pagination_util.dart';
import 'package:flutter/material.dart';
import 'package:dog_pal/utils/extensions_util.dart';

class MateRepo extends PaginationUtil {
  Firestore _db = FirestoreService.getInstance();

  @override
  Query firstQuery;

  @override
  Query secondQuery;

  @override
  Query thirdQuery;

  Future<List<DocumentSnapshot>> getMatingDogs({
    @required String town,
    @required String city,
    @required String district,
    @required String size,
    @required String breed,
    @required String gender,
    @required List<String> colors,
  }) async {
    town == null
        ? firstQuery = null
        : firstQuery = _db
            .collection(FirestoreConsts.MATE_DOGS)
            .where(PostsConsts.TOWN, isEqualTo: town)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyMateFilters(
              gender: gender,
              breed: breed,
              colors: colors,
              size: size,
            );

    city == null
        ? secondQuery = null
        : secondQuery = _db
            .collection(FirestoreConsts.MATE_DOGS)
            .where(PostsConsts.CITY, isEqualTo: city)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyMateFilters(
              gender: gender,
              breed: breed,
              colors: colors,
              size: size,
            );

    district == null
        ? thirdQuery = null
        : thirdQuery = _db
            .collection(FirestoreConsts.MATE_DOGS)
            .where(PostsConsts.DISTRICT, isEqualTo: district)
            .orderBy(PostsConsts.DATE_ADDED, descending: true)
            .applyMateFilters(
              gender: gender,
              breed: breed,
              colors: colors,
              size: size,
            );

    return await super.getDogs();
  }

  Future<List<DocumentSnapshot>> loadMorePosts() async {
    return await super.loadMoreData();
  }
}
