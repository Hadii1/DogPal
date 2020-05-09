import 'dart:async';

import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/bloc_disposal.dart';
import 'package:flutter/material.dart';

class AppBloc implements BlocBase {
  //Will never be called, alive for app lifecycle
  @override
  void dispose() {
    notificationsSender.close();
    postsCtrl.close();
  }

  bool currentlyAdding = false;

  Future<bool> Function() lastFunction;

  DogPost dogPost;

  StreamController<SnackBar> notificationsSender = StreamController.broadcast();
  Stream<SnackBar> get notifications => notificationsSender.stream;

  StreamController<Future<bool> Function()> postsCtrl =
      StreamController.broadcast();

  Stream<Future<bool> Function()> get postsToAddStream => postsCtrl.stream;
}
