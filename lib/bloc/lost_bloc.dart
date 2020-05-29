import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'dart:async';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/repo/lost_repo.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:flutter/services.dart';

class LostBloc extends DogPostsBloc {
  LostBloc(LocalStorage localStorage) : super(localStorage) {
    _lostRepo = LostRepo();
  }

  LostRepo _lostRepo;

  bool _fetching = false;

  @override
  StreamController<DataState> stateCtrl = StreamController.broadcast();
  @override
  Stream<DataState> get dataState => stateCtrl.stream;

  StreamController<int> _activeFiltersCtrl = StreamController.broadcast();
  @override
  Stream<int> get activeFilters => _activeFiltersCtrl.stream;

  @override
  List<DogPost> posts = [];

  /* filters */
  String gender = '';
  String breed = '';
  List<String> coatColors = [];

  bool _shouldRetry = true;

  @override
  void dispose() {
    stateCtrl.close();
    _activeFiltersCtrl.close();
  }

  @override
  Future<void> getPosts() async {
    recountFilters();
    stateCtrl.sink.add(DataState.loading);
    try {
      if (await isOnline()) {
        List<DocumentSnapshot> documents = await _lostRepo.getLostDogs(
          town: super.town,
          city: super.city,
          district: super.district,
          breed: breed,
          colors: coatColors,
          gender: gender,
        );
        if (documents == null) {
          stateCtrl.sink.add(DataState.unknownError);
          return;
        }
        if (documents.isEmpty) {
          stateCtrl.sink.add(DataState.noDataAvailable);
          return;
        }

        posts = documents.map((document) {
          return LostPost.fromDocument(document.data);
        }).toList();

        print('posts: ${posts.length.toString()}');

        _shouldRetry = true;
        stateCtrl.sink.add(DataState.postsAvailable);
      } else {
        stateCtrl.sink.add(DataState.networkError);
      }
    } on PlatformException catch (e) {
      if (_shouldRetry) {
        _shouldRetry = false;
        getPosts();
        return;
      }
      print(e.code ?? e.message);
      stateCtrl.sink.add(DataState.unknownError);
    } on SocketException catch (_) {
      stateCtrl.sink.add(DataState.networkError);
    }
  }

  @override
  Future<void> loadMorePosts() async {
    if (!_fetching) {
      _fetching = true;
      try {
        List<DocumentSnapshot> list = await _lostRepo.loadMoreData();
        if (list != null && list.isNotEmpty) {
          List<LostPost> newList = list.map(
            (doc) {
              return LostPost.fromDocument(doc.data);
            },
          ).toList();

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

  @override
  void recountFilters() {
    int i = 0;

    if (gender.isNotEmpty) {
      i = i + 1;
    }
    if (breed.isNotEmpty) {
      i = i + 1;
    }
    if (coatColors.isNotEmpty) {
      i = i + 1;
    }

    _activeFiltersCtrl.sink.add(i);
  }

  @override
  void clearFilters() async {
    gender = '';
    breed = '';
    coatColors = [];
    _activeFiltersCtrl.sink.add(0);
    await getPosts();
  }
}
