import 'dart:async';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PostDeletionBloc implements BlocBase {
  StreamController<PostDeletionStatus> _statusCtrl =
      StreamController.broadcast();
  Stream<PostDeletionStatus> get operationStatus => _statusCtrl.stream;

  PostDeletionBloc({
    @required this.appBloc,
    @required this.dogPostsBloc,
    @required this.profileBloc,
  });

  final FirestoreService _firestoreService = FirestoreService();
  final AppBloc appBloc;
  final DogPostsBloc dogPostsBloc;
  final ProfileBloc profileBloc;

  @override
  void dispose() {
    _statusCtrl.close();
  }

  void cancelOperation() {
    _statusCtrl.sink.add(PostDeletionStatus.unInitiated);
  }

  Future<void> deletePost(DogPost post) async {
    _statusCtrl.sink.add(PostDeletionStatus.loading);

    String collection;

    switch (post.type) {
      case 'lost':
        collection = FirestoreConsts.LOST_DOGS;
        break;
      case 'adopt':
        collection = FirestoreConsts.ADOPTION_DOGS;
        break;
      case 'mate':
        collection = FirestoreConsts.MATE_DOGS;
        break;

      default:
        throw PlatformException(code: 'Undefined post type');
    }

    try {
      await _firestoreService.deletePost(id: post.id, collection: collection);
      await _firestoreService.deleteImages(post.dog.imagesUrls);

      appBloc.notificationSender.sink.add('Post Deleted ✅');

      //refresh all posts in the app:
      profileBloc.initUserPosts();
      profileBloc.initFavs();
      dogPostsBloc.getPosts();
      _statusCtrl.sink.add(PostDeletionStatus.successful);
    } on Exception {
      _statusCtrl.sink.add(PostDeletionStatus.failed);
    }
  }
}
