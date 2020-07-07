import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog.dart';
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

class AddAdoptionDogBloc implements BlocBase {
  AddAdoptionDogBloc(this._appBloc, this._localStorage) {
    User user = _localStorage.getUser();

    adoptionDog = AdoptionDog(
      dogName: '',
      barkTendencies: 'Moderate',
      energyLevel: 'Regular',
      sheddingLevel: 'Moderate',
      trainingLevel: 'Basic',
      gender: 'Female',
      size: 'Medium',
      age: '',
      breed: DogUtil.getRandomBreed(),
      vaccinated: false,
      pedigree: false,
      petFriendly: false,
      appartmentFriendly: false,
      imagesUrls: [],
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

  final StreamController<PostAdditionState> _stateCtrl =
      StreamController.broadcast();
  Stream<PostAdditionState> get state => _stateCtrl.stream;

  final StreamController<String> _errorCtrl = StreamController();
  Stream<String> get errors => _errorCtrl.stream;

  final AppBloc _appBloc;

  final LocalDataRepositroy _localStorage;

  final FirestoreService _firestoreService = FirestoreService();

  AdoptPost post;

  AdoptionDog adoptionDog;

  List<Asset> assetList = [];
  String description = '';

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

  Future<AdoptPost> addPost() async {
    DocumentReference reference =
        _firestoreService.createDocRef(FirestoreConsts.ADOPTION_DOGS);

    try {
      adoptionDog.imagesUrls = await _firestoreService.saveImagesToNetwork(
        assetList,
        'Adoption Dogs',
      );

      if (adoptionDog.imagesUrls == null || adoptionDog.imagesUrls.isEmpty) {
        return null;
      }

      post = AdoptPost(
        dog: adoptionDog,
        id: reference.documentID,
        town: _localStorage.getPostLocationData().postTown,
        city: _localStorage.getPostLocationData().postCity,
        district: _localStorage.getPostLocationData().postDistrict,
        locationDisplay: _localStorage.getPostLocationData().postDisplay,
        dateAdded: Timestamp.now(),
        description: description,
        type: 'adopt',
      );

      await reference.setData(AdoptPost.toDocument(post));

      return post;
    } on PlatformException catch (e, s) {
      //Delete the images if they were saved before the error
      print(e.message ?? e.code);

      reference.delete();

      if (post != null && post.dog.imagesUrls.isNotEmpty) {
        _firestoreService.deleteImages(post.dog.imagesUrls);
      }

      sentry.captureException(
        exception: e,
        stackTrace: s,
      );

      return null;
    } on Exception {
      return null;
    }
  }
}
