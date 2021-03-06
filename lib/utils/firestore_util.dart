import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

//Singleton
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal() {
    _db = Firestore.instance;
    _storageRef = FirebaseStorage.instance.ref();
  }

  static Firestore _db;
  StorageReference _storageRef;

  static Firestore getInstance() {
    if (_db == null) {
      _db = Firestore.instance;
    }
    return _db;
  }

  Future<void> deletePost({
    @required String id,
    @required String collection,
  }) async {
    DocumentReference ref = _db.collection(collection).document(id);
    await ref.delete();
  }

  Future<void> deleteImages(List<String> urls) async {
    FirebaseStorage firebaseStorage = FirebaseStorage();
    for (String url in urls) {
      StorageReference ref = await firebaseStorage.getReferenceFromUrl(url);
      ref.delete();
    }
  }

  Future<List<String>> saveImagesToNetwork(
    List<Asset> assets,
    String folder,
  ) async {
    List<String> images = [];

    for (Asset asset in assets) {
      ByteData byteData = await asset.getByteData(quality: 80);

      List<int> imageData = byteData.buffer.asUint8List();

      StorageReference ref =
          _storageRef.child('$folder/${asset.name}-${Random().nextInt(9999)}');

      StorageUploadTask task = ref.putData(imageData);

      await task.onComplete.then(
        (StorageTaskSnapshot snapshot) async {
          if (task.isSuccessful) {
            String url = await snapshot.ref.getDownloadURL();
            images.add(url);
          } else {
            throw PlatformException(code: 'Saving Images Failed');
          }
        },
      );
    }
    return images;
  }

  Future<void> deleteUserData(String uid) async {
    //delete user posts
    List<DocumentSnapshot> userDocs = [];

    QuerySnapshot adoptQuery = await _db
        .collection(FirestoreConsts.ADOPTION_DOGS)
        .where(UserConsts.USER_UID, isEqualTo: uid)
        .getDocuments(source: Source.server);

    QuerySnapshot mateQuery = await _db
        .collection(FirestoreConsts.MATE_DOGS)
        .where(UserConsts.USER_UID, isEqualTo: uid)
        .getDocuments(source: Source.server);

    QuerySnapshot lostQuery = await _db
        .collection(FirestoreConsts.LOST_DOGS)
        .where(UserConsts.USER_UID, isEqualTo: uid)
        .getDocuments();

    userDocs.addAll(lostQuery.documents);
    userDocs.addAll(adoptQuery.documents);
    userDocs.addAll(mateQuery.documents);

    for (var doc in userDocs) {
      await doc.reference.delete();
    }

    //delete user info
    DocumentReference reference =
        _db.collection(FirestoreConsts.USER_COLLECTION).document(uid);

    if (reference != null) {
      await reference.delete();
    }
  }

  DocumentReference createDocRef(String collection) {
    return _db.collection(collection).document();
  }

  Future<void> saveUserData(Map<String, dynamic> data, String uid) async {
    await _db
        .collection(FirestoreConsts.USER_COLLECTION)
        .document(uid)
        .setData(data, merge: true);
  }

  Future<List<DocumentSnapshot>> fetchUserPosts(String userUid) async {
    List<DocumentSnapshot> documents = [];

    QuerySnapshot adoptQuery = await _db
        .collection(FirestoreConsts.ADOPTION_DOGS)
        .where(UserConsts.USER_UID, isEqualTo: userUid)
        .getDocuments(source: Source.server);

    QuerySnapshot mateQuery = await _db
        .collection(FirestoreConsts.MATE_DOGS)
        .where(UserConsts.USER_UID, isEqualTo: userUid)
        .getDocuments(source: Source.server);

    QuerySnapshot lostQuery = await _db
        .collection(FirestoreConsts.LOST_DOGS)
        .where(UserConsts.USER_UID, isEqualTo: userUid)
        .getDocuments();

    documents.addAll(adoptQuery.documents);
    documents.addAll(mateQuery.documents);
    documents.addAll(lostQuery.documents);

    return documents;
  }

  Future<Map<String, dynamic>> getUserData(String documentId) async {
    DocumentSnapshot snapshot = await _db
        .collection(FirestoreConsts.USER_COLLECTION)
        .document(documentId)
        .get(source: Source.server);

    return snapshot.data;
  }

  Future<void> saveUserFavs({
    @required String userId,
    List<String> adoptionList,
    List<String> matingList,
  }) async {
    if (adoptionList != null) {
      _db
          .collection(FirestoreConsts.USER_COLLECTION)
          .document(userId)
          .updateData({UserConsts.FAVORITE_ADOPTION: adoptionList});
    }

    if (matingList != null) {
      _db
          .collection(FirestoreConsts.USER_COLLECTION)
          .document(userId)
          .updateData({UserConsts.FAVORITE_MATING: matingList});
    }
  }

  Future<List<DocumentSnapshot>> getFavroiteList(
      List<String> ids, String collection) async {
    List<DocumentSnapshot> docs = [];
    for (String id in ids) {
      DocumentSnapshot snapshot =
          await _db.collection(collection).document(id).get();

      if (snapshot.exists) {
        docs.add(snapshot);
      }
    }

    return docs;
  }
}
