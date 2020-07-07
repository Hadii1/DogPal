import 'dart:async';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:dog_pal/utils/enums.dart';

class AppBloc implements BlocBase {
  AppBloc(this._dogPostsBloc) {
    postsToAddStream.listen(
      (addPost) async {
        if (addPost != null) {
          currentlyAdding = true;
          _operationCtrl.sink.add(PostAdditionStatus.adding);

          dogPost = await addPost().timeout(
            Duration(seconds: 20),
            onTimeout: () => null,
          );

          if (dogPost != null) {
            //Operatoin Success
            _operationCtrl.sink.add(PostAdditionStatus.successful);
            _dogPostsBloc.onUserPostAdded(dogPost);
            lastFunction = null;
          } else {
            //Operatoin Failed
            _operationCtrl.sink.add(PostAdditionStatus.failed);
            lastFunction = addPost;
          }
          currentlyAdding = false;
        }
      },
    );
  }

  DogPostsBloc _dogPostsBloc;

  bool currentlyAdding = false;

  Future<DogPost> Function() lastFunction;

  final StreamController<PostAdditionStatus> _operationCtrl =
      StreamController.broadcast();

  Stream<PostAdditionStatus> get operationStatus => _operationCtrl.stream;

  final StreamController<Future<DogPost> Function()> postsToAddCtrl =
      StreamController.broadcast();

  Stream<Future<DogPost> Function()> get postsToAddStream =>
      postsToAddCtrl.stream;

  final StreamController<String> notificationSender =
      StreamController.broadcast();

  Stream<String> get appNotifications => notificationSender.stream;

  DogPost dogPost;

  //Will never be called, alive for app lifecycle
  @override
  void dispose() {
    _operationCtrl.close();
    notificationSender.close();
    postsToAddCtrl.close();
  }

  void onRetryPressed() {
    postsToAddCtrl.add(lastFunction);
  }
}
