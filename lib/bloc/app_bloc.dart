import 'dart:async';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';

enum OperationStatus {
  adding,
  successful,
  failed,
}

class AppBloc implements BlocBase {
  //Will never be called, alive for app lifecycle
  @override
  void dispose() {
    _operationCtrl.close();
    postsCtrl.close();
  }

  DogPost dogPost;

  AppBloc() {
    postsToAddStream.listen((addPost) async {
      if (addPost != null) {
        currentlyAdding = true;
        _operationCtrl.sink.add(OperationStatus.adding);

        dogPost = await addPost().timeout(
          Duration(seconds: 20),
          onTimeout: () => null,
        );

        if (dogPost != null) {
          _operationCtrl.sink.add(OperationStatus.successful);
          lastFunction = null;
        } else {
          _operationCtrl.sink.add(OperationStatus.failed);
          lastFunction = addPost;
        }
        currentlyAdding = false;
      }
    });
  }

  void onRetryPressed() {
    postsCtrl.add(lastFunction);
  }

  bool currentlyAdding = false;

  Future<DogPost> Function() lastFunction;

  StreamController<OperationStatus> _operationCtrl =
      StreamController.broadcast();

  Stream<OperationStatus> get operationStatus => _operationCtrl.stream;

  StreamController<Future<DogPost> Function()> postsCtrl =
      StreamController.broadcast();

  Stream<Future<DogPost> Function()> get postsToAddStream => postsCtrl.stream;
}
