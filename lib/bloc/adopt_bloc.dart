import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/repo/adopt_repo.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/services.dart';

class AdoptBloc extends DogPostsBloc {
  AdoptBloc(LocalStorage localStorage) : super(localStorage) {
    _adoptRepo = AdoptRepo();
  }

  bool _fetching = false;

  AdoptRepo _adoptRepo;

  StreamController<int> _activeFiltersCtrl = StreamController.broadcast();
  @override
  Stream<int> get activeFilters => _activeFiltersCtrl.stream;

  @override
  StreamController<DataState> stateCtrl = StreamController.broadcast();
  @override
  Stream<DataState> get dataState => stateCtrl.stream;

  @override
  List<DogPost> posts = List();

  /*/*/* Filter fields */*/*/
  String gender = '';
  String breed = '';
  List<String> coatColors = [];
  String trainingLevel = '';
  String energyLevel = '';
  String barkTendencies = '';
  String size = '';

  bool _shouldRetry = true;

  @override
  void dispose() {
    print('disposing');
    _activeFiltersCtrl.close();
    stateCtrl.close();
  }

  @override
  Future<void> getPosts() async {
    stateCtrl.sink.add(DataState.loading);

    recountFilters();
    try {
      if (await isOnline()) {
        List<DocumentSnapshot> list = await _adoptRepo.getAdoptionDogs(
            town: super.town,
            city: super.city,
            district: super.district,
            gender: gender,
            breed: breed,
            coatColors: coatColors,
            trainingLevel: trainingLevel,
            energyLevel: energyLevel,
            barkTendencies: barkTendencies,
            size: size);

        if (list == null) {
          stateCtrl.sink.add(DataState.unknownError);
          return;
        }
        if (list.isEmpty) {
          stateCtrl.sink.add(DataState.noDataAvailable);
          return;
        }

        posts = list.map((doc) {
          return AdoptPost.fromDocument(doc.data);
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
  void clearFilters() {
    gender = '';
    breed = '';
    trainingLevel = '';
    energyLevel = '';
    barkTendencies = '';
    size = '';
    coatColors = [];
    recountFilters();
    getPosts();
  }

  @override
  void recountFilters() {
    int i = 0;

    if (gender.isNotEmpty) {
      i++;
    }
    if (breed.isNotEmpty) {
      i++;
    }
    if (coatColors.isNotEmpty) {
      i++;
    }
    if (trainingLevel.isNotEmpty) {
      i++;
    }
    if (energyLevel.isNotEmpty) {
      i++;
    }
    if (barkTendencies.isNotEmpty) {
      i++;
    }
    if (size.isNotEmpty) {
      i++;
    }
    _activeFiltersCtrl.sink.add(i);
  }

  @override
  void loadMorePosts() async {
    if (!_fetching) {
      _fetching = true;
      try {
        List<DocumentSnapshot> list = await _adoptRepo.loadMoreData();
        if (list != null && list.isNotEmpty) {
          List<AdoptPost> newList = list.map((doc) {
            return AdoptPost.fromDocument(doc.data);
          }).toList();

          posts = newList;

          stateCtrl.sink.add(DataState.postsAvailable);
        }
      } on SocketException {
        notificationCtrl.sink.add('Network problems while fetching posts');
      }

      Future.delayed(Duration(milliseconds: 100), () {
        _fetching = false;
      });
    }
  }
}
