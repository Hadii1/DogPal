import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/dog_util.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class AddMateDogBloc implements BlocBase {
  AddMateDogBloc(this._appBloc, this._localStorage) {
    User user = _localStorage.getUser();
    mateDog = MateDog(
      age: '',
      breed: DogUtil.getRandomBreed(),
      size: 'Medium',
      pedigree: false,
      vaccinated: false,
      dogName: '',
      gender: 'Female',
      imagesUrls: [],
      coatColors: [],
      owner: User(
        username: user.username,
        email: user.email,
        photo: user.photo,
        uid: user.uid,
      ),
    );
  }

  AppBloc _appBloc;

  final LocalStorage _localStorage;

  final FirestoreService _firestoreService = FirestoreService();

  MateDog mateDog;

  MatePost matePost;

  StreamController<PostAdditionState> _stateCtrl = StreamController.broadcast();
  Stream<PostAdditionState> get state => _stateCtrl.stream;

  StreamController<String> _errorCtrl = StreamController();
  Stream<String> get errors => _errorCtrl.stream;

  List<Asset> assets = [];

  Future<void> sendPostToAppBloc() async {
    _stateCtrl.sink.add(PostAdditionState.loading);
    if (await isOnline()) {
      if (_appBloc.currentlyAdding) {
        _errorCtrl.sink.add(
            'Another post is currently being added, kindly hold up until it finishes to add another one');
        return;
      }
      _stateCtrl.sink.add(PostAdditionState.shouldNavigate);
      _appBloc.postsCtrl.sink.add(addPost);
    } else {
      _stateCtrl.sink.add(PostAdditionState.noInternet);
    }
  }

  String description = '';

  @override
  void dispose() {
    _stateCtrl.close();
    _errorCtrl.close();
  }

  Future<bool> addPost() async {
    DocumentReference reference =
        _firestoreService.createDocRef(FirestoreConsts.MATE_DOGS);

    try {
      List<String> urls =
          await _firestoreService.saveImagesToNetwork(assets, 'Mating Dogs');

      if (urls == null || urls.isEmpty) {
        return false;
      }

      mateDog.imagesUrls = urls;

      matePost = MatePost(
        id: reference.documentID,
        town: _localStorage.getPostLocationData()[UserConsts.TOWN],
        city: _localStorage.getPostLocationData()[UserConsts.CITY],
        district: _localStorage.getPostLocationData()[UserConsts.DISTRICT],
        locationDisplay:
            _localStorage.getPostLocationData()[UserConsts.LOCATION_DISPLAY],
        dateAdded: Timestamp.fromDate(DateTime.now()),
        description: description,
        type: 'mate',
        dog: mateDog,
      );

      await reference.setData(MatePost.toDocument(matePost));

      _appBloc.dogPost = matePost;

      return true;
    } on PlatformException catch (e, s) {
      //Delete the images if they were saved before the error
      reference.delete();

      if (matePost != null && matePost.dog.imagesUrls.isNotEmpty) {
        _firestoreService.deleteImages(matePost.dog.imagesUrls);
      }

      sentry.captureException(
        exception: e,
        stackTrace: s,
      );
      return false;
    } on Exception {
      return false;
    }
  }
}
