import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/repo/mate_repo.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/services.dart';

class MateBloc extends DogPostsBloc {
  MateBloc(LocalStorage localStorage) : super(localStorage);

  MateRepo _mateRepo = MateRepo();

  //Filtering fields
  String gender = '';
  String breed = '';
  String size = '';
  List<String> colors = [];

  bool _fetching = false;

  @override
  List<DogPost> posts;

  @override
  StreamController<DataState> stateCtrl = StreamController.broadcast();

  @override
  Stream<DataState> get dataState => stateCtrl.stream;

  @override
  Stream<int> get activeFilters => _activeFiltersCtrl.stream;

  StreamController<int> _activeFiltersCtrl = StreamController.broadcast();

  bool _shouldRetry = true;

  @override
  void clearFilters() {
    gender = '';
    breed = '';
    size = '';
    colors = [];
    _activeFiltersCtrl.sink.add(0);
    recountFilters();
    getPosts();
  }

  @override
  void dispose() {
    stateCtrl.close();
    _activeFiltersCtrl.close();
  }

  @override
  Future<void> getPosts() async {
    stateCtrl.sink.add(DataState.loading);

    recountFilters();
    try {
      if (await isOnline()) {
        List<DocumentSnapshot> list = await _mateRepo.getMatingDogs(
          town: super.town,
          city: super.city,
          district: super.district,
          gender: gender,
          size: size,
          breed: breed,
          colors: colors,
        );

        if (list == null) {
          stateCtrl.sink.add(DataState.unknownError);
          return;
        }

        if (list.isEmpty) {
          stateCtrl.sink.add(DataState.noDataAvailable);
          return;
        }

        posts = list.map((doc) {
          return MatePost.fromMap(doc.data);
        }).toList();

        _shouldRetry = true;
        stateCtrl.sink.add(DataState.postsAvailable);
      } else {
        stateCtrl.sink.add(DataState.networkError);
      }
    } on PlatformException catch (e, s) {
      if (_shouldRetry) {
        _shouldRetry = false;
        getPosts();
        return;
      }
      sentry.captureException(
        exception: e,
        stackTrace: s,
      );
      stateCtrl.sink.add(DataState.unknownError);
    } on SocketException {
      stateCtrl.sink.add(DataState.networkError);
    }
  }

  @override
  void loadMorePosts() async {
    if (!_fetching) {
      _fetching = true;
      try {
        List<DocumentSnapshot> list = await _mateRepo.loadMoreData();
        if (list != null && list.isNotEmpty) {
          List<MatePost> newList = list.map((doc) {
            return MatePost.fromMap(doc.data);
          }).toList();

          posts = newList;
          stateCtrl.sink.add(DataState.postsAvailable);
        }
      } on SocketException {
        stateCtrl.sink.add(DataState.fetchingNetworkError);
      }

      /*/*/* when data is updated, the widget rebuild takes
       time and so the scroll controller doesn't instantly 
       update it's scrolling values and directly makes
       another call to get more data thus doing two batches 
       of data in one scrolling session */*/*/
      Future.delayed(Duration(milliseconds: 100), () {
        _fetching = false;
      });
    }
  }

  @override
  void recountFilters() {
    int i = 0;
    if (gender.isNotEmpty) i++;
    if (size.isNotEmpty) i++;
    if (breed.isNotEmpty) i++;
    if (colors.isNotEmpty) i++;
    _activeFiltersCtrl.sink.add(i);
  }
}
