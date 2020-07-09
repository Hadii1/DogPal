import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/dog_util.dart';
import 'package:dog_pal/utils/enums.dart';
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
    if (!_appBloc.currentlyAdding) {
      if (await isOnline()) {
        _stateCtrl.sink.add(PostAdditionState.shouldNavigate);
        _appBloc.postsToAddCtrl.sink.add(addPost);
      } else {
        _stateCtrl.sink.add(PostAdditionState.noInternet);
      }
    }
  }

  Future<LostPost> addPost() async {
    DocumentReference reference =
        _firestoreService.createDocRef(FirestoreConsts.LOST_DOGS);

    try {
      List<String> urls =
          await _firestoreService.saveImagesToNetwork(assetsList, 'Lost Dogs');

      if (urls == null || urls.isEmpty) {
        return null;
      }

      dog.imagesUrls = urls;

      post = LostPost(
        dog: dog,
        id: reference.documentID,
        type: 'lost',
        description: description,
        town: _localStorage.getPostLocationData().town,
        city: _localStorage.getPostLocationData().city,
        district: _localStorage.getPostLocationData().district,
        locationDisplay: _localStorage.getPostLocationData().display,
        dateAdded: Timestamp.now(),
      );

      await reference.setData(LostPost.toDocument(post));

      return post;
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

      return null;
    } on Exception {
      return null;
    }
  }
}
