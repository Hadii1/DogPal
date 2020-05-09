import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/lost_post.dart';
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

class AddLostDogBloc implements BlocBase {
  AppBloc _appBloc;

  AddLostDogBloc(this._appBloc, this._localStorage) {
    User user = _localStorage.getUser();

    dog = Dog(
      dogName: '',
      gender: 'Female',
      imagesUrls: [],
      breed: DogUtil.getRandomBreed(),
      coatColors: [],
      owner: User(
        username: user.username,
        email: user.email,
        photo: user.photo,
        uid: user.uid,
        phoneNumber: '',
      ),
    );
  }

  @override
  void dispose() {
    _stateCtrl.close();
    _errorCtrl.close();
  }

  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorage _localStorage;

  StreamController<PostAdditionState> _stateCtrl = StreamController.broadcast();
  Stream<PostAdditionState> get state => _stateCtrl.stream;

  StreamController<String> _errorCtrl = StreamController();
  Stream<String> get errors => _errorCtrl.stream;

  Dog dog;

  String description = '';

  List<Asset> assetsList = [];

  int activePicture = 0;

  LostPost post;

  Future<void> sendPostToAppBloc() async {
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

  Future<bool> addPost() async {
    DocumentReference reference =
        _firestoreService.createDocRef(FirestoreConsts.LOST_DOGS);

    try {
      List<String> urls =
          await _firestoreService.saveImagesToNetwork(assetsList, 'Lost Dogs');

      if (urls == null || urls.isEmpty) {
        return false;
      }

      dog.imagesUrls = urls;

      post = LostPost(
        dog: dog,
        id: reference.documentID,
        type: 'lost',
        description: description,
        district: _localStorage.getPostLocationData()[UserConsts.DISTRICT],
        locationDisplay:
            _localStorage.getPostLocationData()[UserConsts.LOCATION_DISPLAY],
        city: _localStorage.getPostLocationData()[UserConsts.CITY],
        town: _localStorage.getPostLocationData()[UserConsts.TOWN],
        dateAdded: Timestamp.now(),
      );

      await reference.setData(LostPost.toDocument(post));

      _appBloc.dogPost = post;

      return true;
    } on PlatformException catch (e, s) {
      sentry.captureException(
        exception: e,
        stackTrace: s,
      );

      //Delete the images if they were saved before the error
      reference.delete();
      if (post != null && post.dog.imagesUrls.isNotEmpty) {
        _firestoreService.deleteImages(post.dog.imagesUrls);
      }

      return false;
    } on Exception {
      return false;
    }
  }
}
